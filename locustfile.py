from locust import HttpUser, task, between

class TrafficLoad(HttpUser):
    wait_time = between(1, 3) 

    @task(3) 
    def browse_main_pages(self):
        self.client.get("/")
        self.client.get("/data_analysis")

    @task(2)
    def get_sensor_data(self):
        sensor_types = ["Humidity", "Temperature", "Pressure"],
        # sensor_types = ["Temperature"]
        limits = [20, 50, 100]
        
        for sensor_type in sensor_types:
            for limit in limits:
                self.client.get(f"http://192.168.49.2:31145/api/data?type={sensor_type}&limit={limit}")

    @task(1)
    def get_min_max_data(self):
        sensor_types = ["Humidity", "Temperature", "Pressure"]
        # sensor_types = ["Temperature"]
        limits = [20, 50, 100]
        
        for sensor_type in sensor_types:
            for limit in limits:
                self.client.get(f"http://192.168.49.2:31145/api/data/min_max?type={sensor_type}&limit={limit}")

    @task(1)
    def export_csv_data(self):
        sensor_types = ["Humidity", "Temperature", "Pressure"]
        # sensor_types = ["Temperature"]
        limits = [20, 50, 100]
        
        for sensor_type in sensor_types:
            for limit in limits:
                self.client.get(f"http://192.168.49.2:31145/api/data/export_to_csv?type={sensor_type}&limit={limit}")