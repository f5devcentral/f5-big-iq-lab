Lab 6.1: HTTP Legacy Application Creation
-----------------------------------------

1. Login to BIG-IQ as **david** by opening a browser and go to: ``https://10.1.1.4``

2. Navigate to Applications > Applications.

.. image:: ../pictures/module6/lab-1-1.png
  :scale: 40%
  :align: center

2. Select Create Application to Create an Application Service:

+----------------------------------------------------------------------------------------------------+
| Application properties:                                                                            |
+----------------------------------------------------------------------------------------------------+
| * Grouping = New Application                                                                       |
| * Application Name = ``LAB_module6``                                                               |
+----------------------------------------------------------------------------------------------------+
| Select Using Existing Device Configuration                                                         |
+----------------------------------------------------------------------------------------------------+
| General Properties:                                                                                |
+----------------------------------------------------------------------------------------------------+
| * Application Service Name = ``legacy-app-service``                                                |
| * Target = ``BOS-vBIGIP01.termmarc.com``                                                           |
| * Application Service Type = ``HTTP + TCP``                                                        |
+----------------------------------------------------------------------------------------------------+
| Virtual Servers: ``vip134``                                                                        |
+----------------------------------------------------------------------------------------------------+

.. image:: ../pictures/module6/lab-1-2.png
  :scale: 40%
  :align: center

Pay attention to the warning next to Analytics profile section. 

You can add up to 5 Virtual IP address to a single Legacy Application service.

.. image:: ../pictures/module6/lab-1-3.png
  :scale: 40%
  :align: center

3. Click on **View Sample API Request** in the right upper corner.

.. image:: ../pictures/module6/lab-1-4.png
  :scale: 40%
  :align: center

4. Go back to the list of objects and click on Profile HTTP Analytics.
   Notice it is missing.

.. image:: ../pictures/module6/lab-1-5.png
  :scale: 40%
  :align: center

.. warning:: Review carefully `K02142132`_: Requirements and recommendations for creating a BIG-IQ application service with existing device configurations

.. _K02142132: https://support.f5.com/csp/article/K02142132

5. Click **Create**.
  
6. Check the Application ``LAB_module6`` has been created.
   Notice the label LEGACY showing on the Application Legacy.

.. image:: ../pictures/module6/lab-1-6.png
  :scale: 40%
  :align: center

Drill down into the Application dashboard and notice no analytics are showing on the dashboard.
This is normal, the VIP does not have any Analytics profiles attached to it.

.. image:: ../pictures/module6/lab-1-7.png
  :scale: 40%
  :align: center


