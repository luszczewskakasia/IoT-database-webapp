# from locust import HttpUser, task
# class TrafficLoad(HttpUser):
#     @task
#     def load_test(self):
#         self.client.get("/")
#         self.client.get("/data_analysis")
#         # self.client.get("/api/data/min_max/limit=100?type=Temperature")
#         # self.client.get("/api/data/export_to_csv")

from locust import HttpUser, task, between

class TrafficLoad(HttpUser):
    wait_time = between(1, 3)  # Wait 1-3 seconds between tasks

    @task(3)  # Higher weight for main pages
    def browse_main_pages(self):
        self.client.get("/")
        self.client.get("/data_analysis")

    @task(2)
    def get_sensor_data(self):
        # Test different sensor types
        sensor_types = ["Temperature", "Pressure", "Humidity"]
        limits = [20, 50, 100]
        
        for sensor_type in sensor_types:
            for limit in limits:
                self.client.get(f"http://localhost:39057/api/data?type={sensor_type}&limit={limit}")

    @task(1)
    def get_min_max_data(self):
        # Test min/max endpoint with different parameters
        sensor_types = ["Temperature", "Pressure", "Humidity"]
        limits = [20, 50, 100]
        
        for sensor_type in sensor_types:
            for limit in limits:
                self.client.get(f"http://localhost:43563/api/data/min_max?type={sensor_type}&limit={limit}")

    @task(1)
    def export_csv_data(self):
        # Test CSV export with different parameters
        sensor_types = ["Temperature", "Pressure", "Humidity"]
        limits = [20, 50, 100]
        
        for sensor_type in sensor_types:
            for limit in limits:
                self.client.get(f"http://localhost:45219/api/data/export_to_csv?type={sensor_type}&limit={limit}")