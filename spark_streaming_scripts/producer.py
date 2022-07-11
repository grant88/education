from time import sleep
from json import dumps
from kafka import KafkaProducer
from random import randrange,choices
import string


producer = KafkaProducer(bootstrap_servers=['localhost:9092'],
                         value_serializer=lambda x:
                         dumps(x).encode('utf-8'))

def push():
    for e in range(1000):
        text = ''.join(choices(string.ascii_uppercase +
                               string.digits, k=20))
        user = {'id': randrange(5), 'action': text}
        producer.send('netology', value=user)
        sleep(randrange(3))
        print("produced message ", e)

try:
    while True:
        push()
except KeyboardInterrupt:
    producer.close()
    print("exit")