package ru.netology.dsw;

import io.confluent.kafka.schemaregistry.client.MockSchemaRegistryClient;
import io.confluent.kafka.serializers.KafkaAvroDeserializer;
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import io.confluent.kafka.serializers.KafkaAvroSerializerConfig;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.apache.kafka.streams.TestInputTopic;
import org.apache.kafka.streams.TestOutputTopic;
import org.apache.kafka.streams.TopologyTestDriver;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import ru.netology.dsw.dsl.AmountAlertsApp;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Map;
import java.util.Random;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;

class AmountAlertsAppTest {
    private final MockSchemaRegistryClient schemaRegistry = new MockSchemaRegistryClient();
    private final StringSerializer stringSerializer = new StringSerializer();
    private final StringDeserializer stringDeserializer = new StringDeserializer();

    private TopologyTestDriver testDriver;
    private TestInputTopic<String, Object> purchasesTopic;
    private TestOutputTopic<String, Object> resultTopic;

    @BeforeEach
    void setUp() {
        var serDeProps = Map.of(
                KafkaAvroSerializerConfig.AUTO_REGISTER_SCHEMAS, "true",
                KafkaAvroSerializerConfig.SCHEMA_REGISTRY_URL_CONFIG, "http://localhost:8090"
        );
        KafkaAvroSerializer avroSerializer = new KafkaAvroSerializer(schemaRegistry, serDeProps);
        KafkaAvroDeserializer avroDeserializer = new KafkaAvroDeserializer(schemaRegistry, serDeProps);
        testDriver = new TopologyTestDriver(AmountAlertsApp.buildTopology(schemaRegistry, serDeProps), AmountAlertsApp.getStreamsConfig());
        purchasesTopic = testDriver.createInputTopic(AmountAlertsApp.PURCHASES_TOTAL_TOPIC, stringSerializer, avroSerializer);
        resultTopic = testDriver.createOutputTopic(AmountAlertsApp.RESULT_AMOUNT_ALERT_TOPIC, stringDeserializer, avroDeserializer);
    }

    @AfterEach
    void tearDown() {
        testDriver.close();
    }

    @Test
    public void shouldAlertIfThereAreManySmallPurchasesOfAProduct() throws Exception {
        Instant twoMinutesAgo = Instant.now().minusSeconds(120);
        for (int i = 0; i < 6; i++) {
            // эмулируем получение шести покупок с количеством 2 две минуты назад
            purchasesTopic.pipeInput(
                    // id сообщения
                    String.valueOf(i),
                    // само сообщение
                    createTotalPurchase(1, 2, 300),
                    // таймстемп сообщения
                    twoMinutesAgo
            );
        }

        var result = resultTopic.readKeyValue();
        assertThat(result.key, is("1"));
        assertThat(
                ((GenericRecord) result.value).get("window_start"),
                // начало окна - это каждая минута в 0 секунд
                is(twoMinutesAgo.truncatedTo(ChronoUnit.MINUTES).toEpochMilli())
        );
        assertThat(((GenericRecord) result.value).get("amount_of_purchases"), is(3600L));
    }

    @Test
    public void shouldAlertIfThereIsOneBigPurchase() throws Exception {
        Instant twoMinutesAgo = Instant.now().minusSeconds(120);
        // эмулируем получение одной большой покупки с количеством 100 две минуты назад
        purchasesTopic.pipeInput(
                // id сообщения
                String.valueOf(123),
                // само сообщение
                createTotalPurchase(1, 100,  300),
                // таймстемп сообщения
                twoMinutesAgo
        );

        var result = resultTopic.readKeyValue();

        assertThat(result.key, is("1"));
        assertThat(
                ((GenericRecord) result.value).get("window_start"),
                // начало окна - это каждая минута в 0 секунд
                is(twoMinutesAgo.truncatedTo(ChronoUnit.MINUTES).toEpochMilli())
        );
        assertThat(((GenericRecord) result.value).get("amount_of_purchases"), is(30000L));
    }

    private GenericRecord createTotalPurchase(long productId, long quantity, long price) {
        GenericRecord total_purchase = new GenericData.Record(TestUtils.createTotalPurchaseSchema());
        total_purchase.put("purchase_id",  new Random().nextLong());
        total_purchase.put("purchase_quantity", quantity);
        total_purchase.put("product_id", productId);
        total_purchase.put("product_price", price);
        return total_purchase;
    }
}
