Lab 5.2: Troubleshooting latency and packet loss
------------------------------------------------

In this lab, we are going to identify latency and packet loss issues happening on an application behind F5.

1. Select the application service ``backend_site20tcp`` located under ``IT_apps`` application.

Notice the alerts raised. The server side RTT exceeded the critical threshold of 100ms.

.. image:: ../pictures/module5/img_module5_lab2_1.png
  :align: center
  :scale: 40%

|

.. note:: If there are no active alerts, look in the alert history.

2. Look for the details of the alert. There is a delay of ~300ms between the F5 BIG-IP and the application server.

.. image:: ../pictures/module5/img_module5_lab2_2.png
  :align: center
  :scale: 40%

|

3. Now, let's look at the Server Side Goodput, especially at the *Connection Duration* under **Remote Host IP Addresses** dimension.

The connection duration metric isn't showing by default in the dimension, you will need to click right and add it. 
Notice one of the pool member is almost double the duration of the other.

.. image:: ../pictures/module5/img_module5_lab2_3.png
  :align: center
  :scale: 40%

|

.. note:: We have added 300ms delay to an nginx running in a docker acting as an application server in this lab.

4. We are now going to remove the healty node and only keep the nginx node. Navigate to the Configuration tab in the application dashboard
   and remove the node ``10.1.20.115:8081``.

.. image:: ../pictures/module5/img_module5_lab2_4.png
  :align: center
  :scale: 40%

|

**Save & Close**.

5. From the lab environment, launch a xRDP/noVNC session to have access to the Ubuntu Desktop. 
To do this, in your lab environment, click on the *Access* button
of the *Ubuntu Lamp Server* system and select *noVNC* or *xRDP*.

.. note:: Modern laptops with higher resolutions you might want to use 1440x900 and once XRDP is launched Zoom to 200%.

Open a terminal and run the following commands:

.. code::

    f5student@ip-10-1-1-5:~$ docker exec nginx tc qdisc change dev eth0 root netem loss 70%

    f5student@ip-10-1-1-5:~$ curl http://10.1.10.124
    curl: (56) Recv failure: Connection reset by peer

You may run the curl command multiple times. Here we removed the delay and add a packet loss of 70%.

6. Back to BIG-IQ Application dashboard, navigate to the **Service Site Packets** and look a the packets loss showing on the dashboard.


.. image:: ../pictures/module5/img_module5_lab2_5.png
  :align: center
  :scale: 40%

|
