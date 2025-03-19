from flask import Flask
from flask import Flask, render_template, redirect, request, url_for
from flask_sqlalchemy import SQLAlchemy
from database import SensorData,  db
import json
import requests
from flask import jsonify

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:postgres@127.0.0.1:5432/postgres"
# db = SQLAlchemy(app)
db.init_app(app)

@app.route("/", methods=['GET', 'POST'])
def home():
    sensor_data = SensorData.query.all()
    return render_template('home.html',sensor_data=sensor_data)
    #   return redirect(url_for('login'))

@app.route('/api/data', methods=['GET'])
def get_data():
    """API Endpoint to get latest records"""
    limit = request.args.get('limit', default=100, type=int)
    sensor_type = request.args.get('type', default='Temperature', type=str)
    sensor_data = SensorData.query.filter(SensorData.sensor_type == sensor_type).order_by(SensorData.id).limit(limit).all()
    formatted_data = [{"timestamp": row.time, "value": row.sensor_value} for row in sensor_data]
    return jsonify(formatted_data)

@app.route("/data_analysis", methods=['GET', 'POST'])
def data_analysis():
    return render_template('data_analysis.html')

@app.route("/login")
def login():
    return render_template('login.html')

@app.route("/register")
def register():
    return render_template('register.html')

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000, debug=True)