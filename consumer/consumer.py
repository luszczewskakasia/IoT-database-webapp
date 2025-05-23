import pika    
import json
import time
# from server import app
from database import SensorData, db
from flask_cors import CORS
from flask import Flask

app = Flask(__name__)
CORS(app)


app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:postgres@sensor_db:5432/postgres"
# db = SQLAlchemy(app)
db.init_app(app)

def wait_for_rabbitmq(host='rabbitmq'):
    for i in range(10):
        try:
            conn = pika.BlockingConnection(pika.ConnectionParameters(host=host))
            return conn
        except pika.exceptions.AMQPConnectionError as e:
            time.sleep(5)

def data_added(ch, method, properties, body):
    body = json.loads(body)
    print(f"Received new sensor data: {body}")

    curr_time = body['time']
    name = body['sensor_type']
    val = body['sensor_value']

    with app.app_context():
        db.session.commit()
        try:
            sensor_data = SensorData(time=curr_time, sensor_type=name, sensor_value=val)
            db.session.add(sensor_data)
            db.session.commit()
        except Exception as e:
            db.session.rollback()
            print(f"Database error: {e}")
            
connection = wait_for_rabbitmq()

channel = connection.channel()

channel.queue_declare(queue='sensor_data')

channel.basic_consume(queue='sensor_data',
                      auto_ack=True,
                      on_message_callback=data_added)

print("Starting...")

channel.start_consuming()