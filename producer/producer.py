import pika 
import requests

r = requests.get('http://127.0.0.1:5000/XD')
print(r.json())

conn_params = pika.ConnectionParameters('localhost')

connection = pika.BlockingConnection(conn_params)
channel = connection.channel()
#queue='queue_name'
channel.queue_declare(queue='sensor_data')
message = r.text
channel.basic_publish(exchange='',routing_key='sensor_data', body=message)
print(f"new sensor data: {message}")
connection.close()

# in while loop or smth like that will request data from sensor