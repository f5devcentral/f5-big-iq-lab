import time
from locust import HttpUser, task, between

# https://docs.locust.io/en/stable/quickstart.html

class QuickstartUser(HttpUser):
    wait_time = between(1, 2)

    @task
    def index_page(self):
        self.client.get("/index.php")
        self.client.get("/contact")
        self.client.get("/wishlist")
        self.client.get("/faq")
        self.client.get("/f5_capacity_issue.php")
        self.client.get("/f5_browser_issue.php")

    @task(3)
    def view_item(self):
        for item_id in range(200):
            self.client.get(f"/product/view?id={item_id}", name="/product-view")
            time.sleep(1)

    def on_start(self):
        self.client.post("/user/login", json={"username":"test_user", "password":"123456"})
