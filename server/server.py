from flask import Flask
from flask import Flask, render_template, redirect, request, url_for
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from database import SensorData, db
from flask import jsonify

app = Flask(__name__)
CORS(app)


app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:postgres@192.168.100.15:5432/postgres"
# db = SQLAlchemy(app)
db.init_app(app)
@app.route("/", methods=['GET', 'POST'])
def home():
    sensor_data = SensorData.query.all()
    print(sensor_data)
    return render_template('home.html',sensor_data=sensor_data)
    #   return redirect(url_for('login'))

# @app.route('/api/data', methods=['GET'])
# def get_data():
#     """API Endpoint to get latest records"""
#     limit = request.args.get('limit', default=100, type=int)
#     sensor_type = request.args.get('type', default='Temperature', type=str)
#     sensor_data = SensorData.query.filter(SensorData.sensor_type == sensor_type).order_by(SensorData.id).limit(limit).all()
#     formatted_data = [{"timestamp": row.time, "value": row.sensor_value} for row in sensor_data]
#     return jsonify(formatted_data)

# @app.route('/api/data/average', methods=['GET'])
# def get_average():
#     """API Endpoint to get average of sensor values"""
#     limit = request.args.get('limit', default=100, type=int)
#     sensor_type = request.args.get('type', default='Temperature', type=str)
#     sensor_data = SensorData.query.filter(SensorData.sensor_type == sensor_type).order_by(SensorData.id).limit(limit).all()
#     average = sum([row.sensor_value for row in sensor_data])/len(sensor_data)
#     return jsonify({"average": average})

# @app.route('/api/data/min_max/last_hour', methods=['GET'])
# def get_min_max_last_hour():
#     """API Endpoint to get average of sensor values"""
#     sensor_type = request.args.get('type', default='Temperature', type=str)
#     sensor_data = SensorData.query.filter(SensorData.sensor_type == sensor_type).order_by(SensorData.id).all()
#     min = np.min([row.sensor_value for row in sensor_data])
#     max = np.max([row.sensor_value for row in sensor_data])
#     return jsonify({"min": min, "max": max})

# @app.route('/api/data/export_to_csv', methods=['GET'])
# def export_to_csv():
#     """API Endpoint to export data to CSV"""
#     sensor_data = SensorData.query.all()
#     with open('sensor_data.csv', 'w') as f:
#         for row in sensor_data:
#             f.write(f"{row.time},{row.sensor_type},{row.sensor_value}\n")
#     return jsonify({"message": "Data exported successfully"})


@app.route("/data_analysis", methods=['GET', 'POST'])
def data_analysis():
    return render_template('data_analysis.html')


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000, debug=True)