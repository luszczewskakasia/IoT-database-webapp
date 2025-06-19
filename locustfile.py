from locust import HttpUser, task
class TrafficLoad(HttpUser):
    @task
    def load_test(self):
        self.client.get("/")
        self.client.get("/data_analysis")
        # self.client.get("/api/data/min_max/limit=100?type=Temperature")
        # self.client.get("/api/data/export_to_csv")