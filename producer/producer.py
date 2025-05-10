import pika 
import requests
import time
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

while True:
    # TODO: to change to the correct port
    r = requests.get('http://rpi:5000/XD')
    print(r.json())

    # TODO: tu bedzie jakis adres z kontneera rabbita. Teraz jest tutaj mój port
    conn_params = pika.ConnectionParameters(host='192.168.100.15')

    connection = pika.BlockingConnection(conn_params)
    channel = connection.channel()
    #queue='queue_name'
    channel.queue_declare(queue='sensor_data')
    message = r.text
    channel.basic_publish(exchange='',routing_key='sensor_data', body=message)
    logging.info(f"Sent message: {message}")
    # print(f"new sensor data: {message}")
    connection.close()
    time.sleep(10)