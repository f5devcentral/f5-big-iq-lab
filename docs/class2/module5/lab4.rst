Lab 5.4: Deploy an application (Azure)
--------------------------------------

.. warning:: A default Application should be already deloy (by admin user). If you want to proceed delete the existing application deployed on the Azure SSG (<YOUR PREFIX>-app-azure).

Deploy your application (optional) - Azure
******************************************

In your ``BIG-IQ UI`` , Go to **Applications** > **Applications** and click on the
**Create** button.

.. image:: ../pictures/module4/img_module4_lab4_1.png
   :align: center
   :scale: 50%

|

Select the template called **Default-AWS-f5-HTTPS-WAF-lb-template**.

.. note:: The AWS default templates can also be used for Azure.

General properties:

* Name: **site-azure.example.com**
* Domain Names: **site-azure.example.com**

.. image:: ../pictures/module5/img_module5_lab4_4.png
   :align: center
   :scale: 50%

|

Select a Traffic Service Environment:

* Environment: Select **Service Scaling Group**
* Service Scaling Group: Select **<YOUR PREFIX>-azure-ssg**

.. image:: ../pictures/module5/img_module5_lab4_5.png
   :align: center
   :scale: 50%

|


* Listeners:

  .. list-table::
     :widths: 15 30 30 30
     :header-rows: 1

     * - **LB PROTOCOL**
       - **LB PORT**
       - **INSTANCE PROTOCOL**
       - **INSTANCE PORT**
     * - TCP
       - 443
       - TCP
       - 443
     * - TCP
       - 80
       - TCP
       - 80

.. image:: ../pictures/module5/img_module5_lab4_6.png
   :align: center
   :scale: 50%

|


Servers:

* Servers: 172.200.1.50 / Port 80

.. image:: ../pictures/module5/img_module5_lab4_7.png
   :align: center
   :scale: 50%

|


Web Application Firewall & Load Balancer:

* Name: default_vs

.. image:: ../pictures/module4/img_module4_lab4_7.png
   :align: center
   :scale: 50%

|

Click on the **Create** button.

After some time, you should see this:

.. image:: ../pictures/module5/img_module5_lab4_8.png
   :align: center
   :scale: 50%

|

Review your ``SSG`` devices setup - Azure
*****************************************

To review the app configuration on the ``SSG`` devices, in your ``BIG-IQ UI``, go to
**Applications** > **Environments** > **Service SCaling Groups**.

Click on your ``SSG`` and then go to **Configuration** > **Devices**. Here you can click
on the Address of one of your devices.

.. image:: ../pictures/module5/img_module5_lab3_9.png
   :align: center
   :scale: 50%

|

.. note::

    * Login: admin
    * Password: <it's in your config.yml file, BIGIP_PWD ATTRIBUTE>

.. image:: ../pictures/module4/img_module4_lab4_9.png
   :align: center
   :scale: 50%

|

.. note:: Keep in mind that because we deploy single nic ``BIG-IPs``, all the VS will
    rely on the self-IP address. Therefore the virtual address we use is 0.0.0.0

Spend some time reviewing your app configuration on your ``SSG Devices``.

Review your ``Azure ALB`` setup - Azure
***************************************

In your ``Azure Console`` , go to **Resource groups** > **<YOUR PREFIX>-azure-ssg**.

Click on the ``Azure ALB`` we specified in the app settings (**<YOUR PREFIX>-azure-ssg-ext-alb**)

Retrieve the DNS Name tied to this ELB:

.. image:: ../pictures/module5/img_module5_lab4_9.png
   :align: center
   :scale: 50%

|

Open a new tab in your browser and go to this DNS name (https)

.. image:: ../pictures/module5/img_module5_lab4_10.png
   :align: center
   :scale: 50%

|

Your application is deployed successfuly.
