from sqlalchemy import create_engine, MetaData, Table, Column, Integer, String, Float, DateTime
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy() 
engine = create_engine("postgresql://postgres:postgres@sensor-db-postgresql/postgres", echo=True)

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
