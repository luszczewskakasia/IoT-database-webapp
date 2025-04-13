from flask import Flask, jsonify
from flask import request
from flask_sqlalchemy import SQLAlchemy
from database.database import SensorData, db
import numpy as np
app = Flask(__name__)

@app.route('/api/data/min_max/last_hour', methods=['GET'])
def get_min_max_last_hour():
    """API Endpoint to get average of sensor values"""
    sensor_type = request.args.get('type', default='Temperature', type=str)
    sensor_data = SensorData.query.filter(SensorData.sensor_type == sensor_type).order_by(SensorData.id).all()
    min = np.min([row.sensor_value for row in sensor_data])
    max = np.max([row.sensor_value for row in sensor_data])
    return jsonify({"min": min, "max": max})

@app.route('/api/data/average', methods=['GET'])
def get_average():
    """API Endpoint to get average of sensor values"""
    limit = request.args.get('limit', default=100, type=int)
    sensor_type = request.args.get('type', default='Temperature', type=str)
    sensor_data = SensorData.query.filter(SensorData.sensor_type == sensor_type).order_by(SensorData.id).limit(limit).all()
    average = sum([row.sensor_value for row in sensor_data])/len(sensor_data)
    return jsonify({"average": average})

