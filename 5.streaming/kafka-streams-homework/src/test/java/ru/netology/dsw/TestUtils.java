package ru.netology.dsw;

import org.apache.avro.Schema;
import org.apache.avro.SchemaBuilder;

public class TestUtils {
    public static Schema createTotalPurchaseSchema() {
        return SchemaBuilder.record("Purchase").fields()
                .requiredLong("product_id")
                .requiredLong("product_price")
                .requiredLong("purchase_id")
                .requiredLong("purchase_quantity")
                .endRecord();
    }
}
