from flask import Flask
from flask import Flask, render_template, redirect, url_for
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:postgres@127.0.0.1:5432/postgres"
db = SQLAlchemy(app)

class SensorData(db.Model):
    __tablename__ = 'sensor_data'
    id = db.Column(db.Integer, primary_key=True)
    time = db.Column(db.String)
    sensor_type = db.Column(db.String)
    sensor_value = db.Column(db.Float)

    def __init__(self, time, sensor_type, sensor_value):
        self.time = time
        self.sensor_type = sensor_type
        self.sensor_value = sensor_value   

@app.route("/")
def home():
    sensor_data = SensorData.query.order_by(SensorData.time.desc()).limit(10).all()
    return render_template('home.html',sensor_data=sensor_data)
    #   return redirect(url_for('login'))

@app.route("/login")
def login():
    return render_template('login.html')

@app.route("/register")
def register():
    return render_template('register.html')

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000, debug=True)