# installation single node mode
# download and unzip into /mnt/d/netology/
tar -xvf kafka_2.12-3.2.0.tar
sudo apt update
sudo apt install openjdk-16-jre-headless
sudo apt install python3
pip3 install pyspark
pip3 install kafka-python

# if exists
sudo rm -rf /tmp/kafka-logs/
sudo rm -rf /tmp/zookeeper

cd /mnt/d/netology/kafka_2.12-3.2.0

# window 1
sudo bin/zookeeper-server-start.sh config/zookeeper.properties

# window 2
sudo bin/kafka-server-start.sh config/server.properties

# window 3
sudo bin/kafka-console-consumer.sh --topic netology --from-beginning --bootstrap-server localhost:9092 

# window 4
cd /mnt/d/netology/spark_streaming_scripts
python3 producer.py

# window 5
sudo export SPARK_LOCAL_IP=127.0.0.1 
# check
sudo spark-shell
# run app
sudo spark-submit --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.2.0 structure_streaming_kafka.py
