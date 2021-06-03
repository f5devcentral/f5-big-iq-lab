Lab 3.2: Application Service creation using AS3 through BIG-IQ GUI
------------------------------------------------------------------

.. note:: Estimated time to complete: **10 minutes**

.. include:: /accesslab.rst

HTTPS Service using AS3 through GUI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Now logout from the **david** session and login to BIG-IQ as **paula**.

2. Click **Create** to create an Application Service and look for the template ``AS3-F5-HTTPS-offload-lb-existing-cert-template-big-iq-default-v1 [AS3]``.

.. warning:: You will notice that the template is not available. If we want **paula** to deploy this template, we first need to have those templates assigned to her via an administrator. 

+------------------------------------------------------------------------------------------------------+
| Application properties:                                                                              |
+------------------------------------------------------------------------------------------------------+
| * Grouping = ``New Application``                                                                     |
| * Application Name = ``LAB_module3``                                                                 |
| * Description = ``My first AS3 template deployment through a GUI``                                   |
+------------------------------------------------------------------------------------------------------+
| Select an Application Service Template:                                                              |
+------------------------------------------------------------------------------------------------------+
| * Template Type = Select ``AS3-F5-HTTPS-offload-lb-existing-cert-template-big-iq-default-v1 [AS3]``  |
+------------------------------------------------------------------------------------------------------+

3. Logout as **paula** and login to BIG-IQ as **david**. (if asked: Leave site? Select: Leave)

4. Select **Applications > Application Templates** and notice the ``Published`` templates.
   The template **paula** wants to use must be listed as a ``Published`` template.

.. image:: ../pictures/module3/lab-2-1.png
  :scale: 60%
  :align: center

5. Go to **System > Role Management > Roles** and select **Application Roles** under the **CUSTOM ROLES** section.
   Here you will see the collection of the Custom Application Roles. 

.. image:: ../pictures/module3/lab-2-2.png
  :scale: 60%
  :align: center

6. User **paula** is assigned to the exiting ``Application Creator VMware`` custom role. Select it and scroll down to AS3 Templates section.
   As you can see, **paula** does not have permission to deploy an AS3 application using ``AS3-F5-HTTPS-offload-lb-existing-cert-template``.

.. image:: ../pictures/module3/lab-2-3.png
  :scale: 60%
  :align: center

7. Select ``AS3-F5-HTTPS-offload-lb-existing-cert-template-big-iq-default-v1`` AS3 Template and 
   click the arrow to get it in the ``Selected`` section. Then, click on **Save & Close**.

8. Logout as **david** and log back in as **paula** and click **Create** application.

9. Click **Create** to create an Application Service:

+----------------------------------------------------------------------------------------------------+
| Application properties:                                                                            |
+----------------------------------------------------------------------------------------------------+
| * Grouping = ``New Application``                                                                   |
| * Application Name = ``LAB_module3``                                                               |
| * Description = ``My first AS3 template deployment through a GUI``                                 |
+----------------------------------------------------------------------------------------------------+
| Select an Application Service Template:                                                            |
+----------------------------------------------------------------------------------------------------+
| * Template Type = Select ``AS3-F5-HTTPS-offload-lb-existing-cert-template-big-iq-default-v1 [AS3]``|
+----------------------------------------------------------------------------------------------------+
| General Properties:                                                                                |
+----------------------------------------------------------------------------------------------------+
| * Application Service Name = ``https_app_service``                                                 |
| * Target = ``SEA-vBIGIP01.termmarc.com``                                                           |
| * Tenant = ``tenant1``                                                                             |
+----------------------------------------------------------------------------------------------------+
| Pool                                                                                               |
+----------------------------------------------------------------------------------------------------+
| * Members: ``10.1.20.120``, port ``80``                                                            |
| * Members: ``10.1.20.121``, port ``80``                                                            |
+----------------------------------------------------------------------------------------------------+
| TLS_Server. Keep default.                                                                          |
+----------------------------------------------------------------------------------------------------+
| Certificate. Keep default.                                                                         |
+----------------------------------------------------------------------------------------------------+
| Service_HTTPS                                                                                      |
+----------------------------------------------------------------------------------------------------+
| * Virtual addresses: ``10.1.10.120``                                                               |
+----------------------------------------------------------------------------------------------------+
| Analytics_Profile. Keep default.                                                                   |
+----------------------------------------------------------------------------------------------------+

.. image:: ../pictures/module3/lab-2-4.png
  :scale: 40%
  :align: center

.. note:: The AS3 naming convention for **TLS Server** and **TLS Client** differs from traditional BIG-IP terminology to better comply with industry usage, 
          but may be slightly confusing for long-time BIG-IP users. The AS3 TLS_Server class is for connections arriving to the BIG-IP, which creates a 
          “client SSL profile” object on the BIG-IP. The AS3 TLS_Client class if for connections leaving the BIG-IP, which creates a “server SSL profile” on 
          the BIG-IP. See TLS_Server and TLS_Client in the Schema Reference for more information 
          ([More Tips and Warning](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/userguide/tips-warnings.html)).
          
10. Click on **View Sample API Request** in the right upper corner. This will display the full AS3 declaration generated by BIG-IQ user interface. 
    Scroll through it, then click to **close**.
	
.. image:: ../pictures/module3/lab-2-5.png
  :scale: 40%
  :align: center
	
11. Click **Create**. BIG-IQ is sending the AS3 declaration to **SEA-vBIGIP01.termmarc.com** and is creating the application service
    on the BIG-IQ dashboard, as well as a manager and a viewer roles associated to this app service.

12. Check the application ``LAB_module3`` has been created.

.. note:: If not visible, refresh the page. It can take few seconds for the application service to appears on the dashboard.

.. image:: ../pictures/module3/lab-2-6.png
  :scale: 40%
  :align: center

13.	Select ``LAB_module3`` Application. You will notice ``LAB_module3`` acts as a group of Application Services where underneath 
multiple services can be grouped. The next window will show you that a new Application Service has been created named ``tenant1_https_app_service``.

.. image:: ../pictures/module3/lab-2-7.png
  :scale: 40%
  :align: center

14.	Now, let's look on the BIG-IP and verify the application is correctly deployed in partition ``tenant1``.
Login to ``SEA-vBIGIP01.termmarc.com`` BIG-IP from lab environment (admin/purple123). Select the partition ``tenant1`` and look at the objects created on the BIG-IP.

.. image:: ../pictures/module3/lab-2-8.png
  :scale: 40%
  :align: center

15.	You can test the HTTPS offload application service by opening Google Chrome browser on the **Ubuntu Jumphost** and type the Virtual Server IP address.

Navigate on the website ``https://10.1.10.120``.

.. note:: Accept the private certificates.

.. image:: ../pictures/module3/lab-2-9.png
  :scale: 40%
  :align: center

16. Back on the BIG-IQ as **paula**, select ``tenant1_https_app_service`` Application Service and look HTTP traffic analytics.

.. image:: ../pictures/module3/lab-2-10.png
  :scale: 40%
  :align: center
  
.. note:: An HTTP traffic generator is running on the Jump host sending traffic through the application service.
