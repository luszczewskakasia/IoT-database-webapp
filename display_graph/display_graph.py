from flask import Flask, jsonify
from flask import request
from flask_cors import CORS
from database import SensorData, db
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:postgres@sensor_db/postgres"

db.init_app(app)
CORS(app)

@app.route('/api/data', methods=['GET'])
def get_data():
    """API Endpoint to get latest records"""
    limit = request.args.get('limit', default=100, type=int)
    sensor_type = request.args.get('type', default='Temperature', type=str)
    sensor_data = SensorData.query.filter(SensorData.sensor_type == sensor_type).order_by(SensorData.id.desc()).limit(limit).all()[::-1]
    formatted_data = [{"timestamp": row.time, "value": row.sensor_value} for row in sensor_data]
    return jsonify(formatted_data)