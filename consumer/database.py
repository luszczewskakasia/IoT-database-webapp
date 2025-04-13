from sqlalchemy import create_engine, MetaData, Table, Column, Integer, String, Float, DateTime
from sqlalchemy.orm import sessionmaker, scoped_session
from sqlalchemy.ext.declarative import declarative_base
import psycopg2
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy() 
engine = create_engine("postgresql://postgres:postgres@127.0.0.1:5432/postgres", echo=True)

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

# Session = sessionmaker(bind=engine)

# Base = declarative_base()
# Base.query = Session.query_property()

# class SensorData(Base):
#     __tablename__ = 'sensor_data'
#     id = Column(Integer, primary_key=True)
#     time = Column(String)
#     sensor_type = Column(String)
#     sensor_value = Column(Float)

#     def __init__(self, time, sensor_type, sensor_value):
#         self.time = time
#         self.sensor_type = sensor_type
#         self.sensor_value = sensor_value