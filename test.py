import simpy
import random 
import datetime
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/XD')
def index():
    dtime = datetime.datetime.now()
    val = round(random.uniform(20,30),2)
    curr_time = dtime.strftime("%H:%M:%S")
    return jsonify({"time": curr_time, "sensor_type": "Temperature", "sensor_value": val})