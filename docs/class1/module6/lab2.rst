Lab 6.2: HTTP Analytics Profile Creation for Legacy Applications
----------------------------------------------------------------

In this lab, David is going to create an HTTP analytics profile and attach it to
the VIP for the legacy application you just created. This will enable the BIG-IP to send HTTP analytics to the BIG-IQ and populate
the dashboard.

1. Go to **Configuration > Local Traffic > Profiles** and look at all existing analytics profiles
   available in this BIG-IQ. You can use the filter to look for a specific profile.

.. image:: ../pictures/module6/lab-2-1.png
  :scale: 40%
  :align: center

2. Let's create a new HTTP analytics profile. Click **Create**. 
   
- Name: ``module6_analytics_profile``
- Type: ``Profile HTTP Analytics``
- Collected Statistics Internal Logging: ``Enabled``

.. image:: ../pictures/module6/lab-2-2.png
  :scale: 40%
  :align: center

- Max TPS and Throughput: ``Enabled``
- HTTP Timing (RTT, TTFB, Duration): ``Enabled``
- URLs: ``Enabled``
- Client IP Addresses: ``Enabled``
- Response Codes: ``Enabled``
- User Agents: ``Enabled``
- Methods: ``Enabled``

.. image:: ../pictures/module6/lab-2-3.png
  :scale: 40%
  :align: center

**Save & Close**.

3. Go to **Configuration > Local Traffic > Virtual Servers** and filter on ``vip134``.

.. image:: ../pictures/module6/lab-2-4.png
  :scale: 40%
  :align: center


4. Edit one of the VIPs and attach the ``module6_analytics_profile``.

.. note:: You only need to update one of the 2 VIPs as the VIP is located on a BIG-IP cluster.
          BIG-IQ will update the other VIPs automatically.

.. image:: ../pictures/module6/lab-2-5.png
  :scale: 40%
  :align: center

Click **Save & Close**. Once completed select the 2 VIPS and click on **Deploy** under the **More** button.
Here you will be deploying the change that attached the new analytics profile to the virtual server. We are deploying to 
both VS's, as they are within a cluster. 

.. image:: ../pictures/module6/lab-2-6.png
  :scale: 40%
  :align: center

The deployment window opens. Type a name, select ``Deploy immediately`` for the Method.

Under the Target Device(s) section, click on ``Find Relevant Devices``
and select the **BOS-vBIGIP01.termmarc.com** and **BOS-vBIGIP02.termmarc.com** and move them over to the 
section markered **Selected**. Then, click on Deploy.

.. note:: Notice you do not need to select the HTTP analytics profile but only the VIP.
          By having *Supporting Objects* option enabled, the deployment will include all objects that 
          the selected object depends on.

.. image:: ../pictures/module6/lab-2-7.png
  :scale: 40%
  :align: center

Click **Deploy**, and then click **Deploy** in the Deploy Immediately warning. 

Wait for the deployment to complete.

.. image:: ../pictures/module6/lab-2-8.png
  :scale: 40%
  :align: center

5. Back on the Applications tab > Applications, go back to the ``legacy-app-service``.
   Under Traffic Management > Configuration > Profile HTTP Analytics, notice the warning disappeared.

.. image:: ../pictures/module6/lab-2-9.png
  :scale: 40%
  :align: center

6. From the lab environment, launch a xRDP/noVNC session to have access to the Ubuntu Desktop. 
To do this, in your lab environment, click on the *Access* button
of the *Ubuntu Lamp Server* system and select *noVNC* or *xRDP*.

.. note:: Modern laptops with higher resolutions you might want to use 1440x900 and once XRDP is launched Zoom to 200%.

Open Chrome and Firefox and navigate on the website http\:\/\/site34.example.com.

.. note:: Accept the private certificates.

.. image:: ../pictures/module6/lab-2-10.png
  :scale: 40%
  :align: center


7. Back on the BIG-IQ Application dashboard, notice the HTTP traffic starts to appear. This means you have successfully 
attached the HTTP profile to the virtual server. In real-world environments F5 recommends that customers experiment with 
a samll number of legacy applications. BIG-IP resource consumption of memory and CPU should be be monitored both before and after 
analytics have been enabled. We do not recommend bulk enabling too many applications at once as it may put added burden on BIG-IP or BIG-IQ.
Proper sizing should be done ahead of time, and new applications should be enabled carefully.

.. image:: ../pictures/module6/lab-2-11.png
  :scale: 40%
  :align: center

8. By the way, did you see the new **Feedback** link on the top right? This is a feature that quite a few customers have requested.
They want a way to submit feedback on the BIG-IQ UI so it gets right to the developers. This is not meant as a substitute for a support case.
It is intended to give customers a means of providing feedback on workflows and navigation within the UI. It will take them to a brief survey monkey 
link where they can answer a few questions and provide their feedback. This is one way of capturing customer input directly
on how we can improve the product.

.. image:: ../pictures/module6/lab-2-12.png
  :scale: 40%
  :align: center
