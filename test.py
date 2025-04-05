import simpy
import random 
import datetime
# import time
# from venv.server import app
# from venv.database import engine, SensorData, Session, db


# Base.metadata.create_all(engine)
# session = Session()

# def sensor(env, name, interval):
#     with app.app_contex():
#         while True:
#             # yield env.timeout(interval)
#             dtime = datetime.datetime.now()
#             val = round(random.uniform(20,30),2)
#             curr_time = dtime.strftime("%H:%M:%S")
#             # print(f'{curr_time}: {name} - {val}')
#             db.session.commit()
#             try:
#                 sensor_data = SensorData(time=curr_time, sensor_type=name, sensor_value=val)
#                 db.session.add(sensor_data)
#                 db.session.commit()
#             except Exception as e:
#                 db.session.rollback()
#                 print(f"Database error: {e}")
#             time.sleep(5)
        
# env = simpy.Environment()
# env.process(sensor(env, 'Temperature', 2))
# env.run(until=10)

from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/XD')
def index():
    dtime = datetime.datetime.now()
    val = round(random.uniform(20,30),2)
    curr_time = dtime.strftime("%H:%M:%S")
    return jsonify({"time": curr_time, "sensor_type": "Temperature", "sensor_value": val})