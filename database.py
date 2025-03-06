from sqlalchemy import create_engine, MetaData, Table, Column, Integer, String, Float, DateTime
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
import psycopg2

engine = create_engine("postgresql://postgres:postgres@127.0.0.1:5432/postgres", echo=True)


# engine = create_engine('sqlite:///sensor_database.db', echo=True)

meta = MetaData()

Session = sessionmaker(bind=engine)

Base = declarative_base()

class SensorData(Base):
    __tablename__ = 'sensor_data'
    id = Column(Integer,primary_key=True)
    time = Column(String)
    sensor_type = Column(String)
    sensor_value = Column(Float)

    def __init__(self, time, sensor_type, sensor_value):
        self.time = time
        self.sensor_type = sensor_type
        self.sensor_value = sensor_value

