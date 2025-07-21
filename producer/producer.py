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
            conn = pika.BlockingConnection(parameters)
            return conn
        except pika.exceptions.AMQPConnectionError as e:
            time.sleep(5)

while True:
    connection = wait_for_rabbitmq()
    channel = connection.channel()
    channel.queue_declare(queue='sensor_data')
    try:
        for port in range(7001, 7011):
            url = f'http://192.168.100.15:{port}/XD'
            try:
                r = requests.get(url)
                if r.status_code == 200:
                    print(r.json())
                    message = r.text
                    channel.basic_publish(exchange='', routing_key='sensor_data', body=message)
                    logging.info(f"Sent message from port {port}: {message}")
            except requests.exceptions.RequestException as req_err:
                logging.error(f"Error connecting to {url}: {req_err}")
        time.sleep(10)
    except Exception as e:
        logging.error(f"Error connecting to RabbitMQ: {e}")
        time.sleep(10)