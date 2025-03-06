import simpy
import random 
import datetime
import time
from database import Base, engine, SensorData, Session


Base.metadata.create_all(engine)
session = Session()

def sensor(env, name, interval):
    while True:
        # yield env.timeout(interval)
        dtime = datetime.datetime.now()
        val = round(random.uniform(20,30),2)
        curr_time = dtime.strftime("%H:%M:%S")
        # print(f'{curr_time}: {name} - {val}')
        session.commit()
        try:
            sensor_data = SensorData(time=curr_time, sensor_type=name, sensor_value=val)
            session.add(sensor_data)
            session.commit()
        except Exception as e:
            session.rollback()
            print(f"Database error: {e}")
        time.sleep(5)
        
env = simpy.Environment()
env.process(sensor(env, 'Temperature', 2))
env.run(until=10)