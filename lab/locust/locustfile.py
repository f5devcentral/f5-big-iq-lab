import time
from locust import HttpUser, task, between

# https://docs.locust.io/en/stable/quickstart.html

class QuickstartUser(HttpUser):
    wait_time = between(5, 10)

    @task
    def index_page(self):
        self.client.get("/index.php")
        self.client.get("/contact")
        self.client.get("/wishlist")
        self.client.get("/faq")
        self.client.get("/product/view?id=72")
        self.client.get("/product/view?id=64")
        self.client.get("/product/view?id=56")

    def on_start(self):
        self.client.post("/user/login", json={"username":"test_user", "password":"123456"})
