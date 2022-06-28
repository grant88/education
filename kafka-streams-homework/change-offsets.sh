sh /usr/local/Cellar/kafka/2.6.0/libexec/bin/kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 \
  --group QuantityAlertsAppDSL \
  --topic purchases:0 \
  --reset-offsets \
  --to-offset 0 \
  --execute
