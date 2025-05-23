from flask import Flask, jsonify
from flask import request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from database import SensorData, db
import numpy as np

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:postgres@sensor_db/postgres"
db.init_app(app)
CORS(app)

@app.route('/api/data/min_max', methods=['GET'])
def get_min_max_last_hour():
    """API Endpoint to get average of sensor values"""
    limit = request.args.get('limit', default=20, type=int)
    sensor_type = request.args.get('type', default='Temperature', type=str)
    sensor_data = SensorData.query.filter(SensorData.sensor_type == sensor_type).order_by(SensorData.id).limit(limit).all()
    min = np.min([row.sensor_value for row in sensor_data])
    max = np.max([row.sensor_value for row in sensor_data])
    average = sum([row.sensor_value for row in sensor_data])/len(sensor_data)
    return jsonify({"min": min, "max": max, "average": average})
