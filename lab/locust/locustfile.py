import time
from locust import HttpUser, task, between

# https://docs.locust.io/en/stable/quickstart.html

class QuickstartUser(HttpUser):
    wait_time = between(5, 10)

    @task
    def index_page(self):
        self.client.get("/index.php", verify=False)
        self.client.get("/contact", verify=False)
        self.client.get("/wishlist", verify=False)
        self.client.get("/faq", verify=False)
        self.client.get("/product/view?id=72", verify=False)
        self.client.get("/product/view?id=64", verify=False)
        self.client.get("/product/view?id=56", verify=False)

    def on_start(self):
        self.client.post("/user/login", json={"username":"test_user", "password":"123456"}, verify=False)
