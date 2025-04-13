from flask import Flask, jsonify
from flask import request, make_response
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from database import SensorData, db
import io, csv

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:postgres@127.0.0.1:5432/postgres"
db.init_app(app)
CORS(app)


@app.route('/api/data/export_to_csv', methods=['GET'])
def export_to_csv():
    print("dupa")
    dest = io.StringIO()
    writer = csv.writer(dest)
    sensor_data = SensorData.query.all()
    for row in sensor_data:
        writer.writerow([row.time, row.sensor_type, row.sensor_value])
    output = make_response(dest.getvalue())
    # output.headers["Content-Disposition"] = "attachment; filename=sensor_data.csv"
    output.headers["Content-type"] = "text/plain"
    return output