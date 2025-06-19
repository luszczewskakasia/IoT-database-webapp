import pika 
import requests
import time
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def wait_for_rabbitmq(host='rabbitmq'):
    credentials = pika.PlainCredentials('guest', 'guest')
    parameters = pika.ConnectionParameters(
        host=host,
        port=5672,
        virtual_host='/',
        credentials=credentials
    )
    for i in range(10):
        try:
            conn = pika.BlockingConnection(parameters) # z chatu
            # conn = pika.BlockingConnection(pika.ConnectionParameters(host=host))
            return conn
        except pika.exceptions.AMQPConnectionError as e:
            time.sleep(5)

while True:
    # TODO: to change to the correct port
    connection = wait_for_rabbitmq()
    channel = connection.channel()
    channel.queue_declare(queue='sensor_data')
    try:
        r = requests.get('http://192.168.100.15:7001/XD')
        print(r.json())
        message = r.text
        channel.basic_publish(exchange='',routing_key='sensor_data', body=message)
        logging.info(f"Sent message: {message}")
        # print(f"new sensor data: {message}")
        # connection.close()
        time.sleep(10)
    except Exception as e:
        logging.error(f"Error connecting to RabbitMQ: {e}")
        time.sleep(10)