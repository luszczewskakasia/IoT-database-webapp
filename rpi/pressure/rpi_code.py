from flask import Flask, jsonify
import random
import datetime

app = Flask(__name__)

@app.route('/XD')
def index():
    dtime = datetime.datetime.now()
    val = round(random.uniform(950, 1050), 2)
    curr_time = dtime.strftime("%H:%M:%S")
    return jsonify({"time": curr_time, "sensor_type": "Pressure", "sensor_value": val})
