from flask import Flask, jsonify
from flask import request, make_response
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from database import SensorData, db
import io, csv

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:postgres@sensor-db-postgresql:5432/postgres"
db.init_app(app)
CORS(app)

@app.route('/api/data/export_to_csv', methods=['GET'])
def export_to_csv():
    dest = io.StringIO()
    writer = csv.writer(dest)
    writer.writerow(['Timestamp', 'Sensor Type', 'Value'])
    limit = request.args.get('limit', default=20, type=int)
    sensor_type = request.args.get('type', default='Temperature', type=str)
    sensor_data = SensorData.query.filter_by(sensor_type=sensor_type).limit(limit).all()
    for row in sensor_data:
        writer.writerow([row.time, row.sensor_type, row.sensor_value])
    output = make_response(dest.getvalue())
    output.headers["Content-Disposition"] = f"attachment; filename=sensor_data_{sensor_type}_{limit}.csv"
    output.headers["Content-type"] = "text/csv"
    output.headers["Access-Control-Allow-Origin"] = "*"
    return output