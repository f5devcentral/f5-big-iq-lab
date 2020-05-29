Lab 2.5: Integrating Let's Enrypt with BIG-IQ for Certificate Management
------------------------------------------------------------------------

.. warning:: If you already created an AWS Application in Class 2 Module 4 (AWS SSG) or Class 5 Module 8 (VE creation),\
             you do not need to recreate this item.

In this lab, we are going to do the initial authentication/validation with the Let's Encrypt servers.
Then create a certificate request and key using BIG-IQ and sign it with Let's Encrypt stage server.
Finally, the last step will be to deploy the new certificate and key to a BIG-IP and create an 
HTTPS Application Service using AS3 to serve the Web Application and do HTTPS offload.


More information in `BIG-IQ Knowledge Center`_ and `Let’s Encrypt website`_.

.. _`BIG-IQ Knowledge Center`: https://techdocs.f5.com/en-us/bigiq-7-1-0/integrating-third-party-certificate-management.html
.. _Let’s Encrypt website: https://letsencrypt.org/how-it-works/


Demo web server and Domain name setup in AWS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To do this lab, we will need a real domain name and a web server accessible from the Let's Encrypt servers.
We will start by deploying the web server (simple Hello World Java Web App) on a EC2 instance in AWS.

1. Create the AWS environment and VPN

SSH Ubuntu host in lab environment:

.. image:: ../../pictures/udf_ubuntu_ssh.png
    :align: left
    :scale: 60%

Navigate to: ``cd f5-aws-vpn-ssg``

Execute the Ansible scripts to create the AWS resources (including VPN between AWS and the lab), cloud provider and cloud environment.

``./000-RUN_ALL.sh vpn``

.. note:: VPN object and servers can take up to 15 minutes to complete.

The console will output your ephemeral credentials for the resources created as well as 
the demo web server public IP running in AWS. Save these for later use.

2. We are going to use for this lab one of the below wildcard DNS services along with the demo web server public IP address in AWS.

This will give us a valid domain name to use to generate a certificate with Let's Encrypt.

We are going to use a domain name like lab.webapp.34.219.3.233.nip.io resolves to IP address 34.219.3.233.

+-----------------------+-------------------------------------------------+
| Wildcard DNS services |                    Example                      |
+=======================+=================================================+
| xip.io                | ``http://lab.webapp.34.219.3.233.xip.io/``      |
+-----------------------+-------------------------------------------------+
| nip.io                | ``http://lab.webapp.34.219.3.233.nip.io/``      |
+-----------------------+-------------------------------------------------+
| sslip.io              | ``http://lab.webapp.34.219.3.233.sslip.io/``    |
+-----------------------+-------------------------------------------------+

.. note:: Replace ``lab.webapp.34.219.3.233.nip.io`` and ``34.219.3.233`` with the correct wildcard DNS services 
          and demo web server public IP address in AWS.

3. Let's use nip.io service for the remaining of the lab.

Open a browser and navigate to ``http://lab.webapp.34.219.3.233.nip.io``

.. image:: ./media/img_module2_lab5-1.png
  :scale: 60%
  :align: center

This is our demo web server is available on port 80 (HTTP).

4. This demo web server is hosting an API call to automatically deploy challenge resources to it.

The API available for automatic deploy the HTTP challenge file is ``http://lab.webapp.34.219.3.233.nip.io/hello``

For demo purpose, the API call is showing current HTTP challenge file(s) if any available on the demo web server.
Note the challenge file must be located under ``.well-known/acme-challenge`` at the root of the web site.

The location is defined by IETF and used to demonstrate ownership of a domain.

.. image:: ./media/img_module2_lab5-2.png
  :scale: 60%
  :align: center


Here is the API call the BIG-IQ does to the Web App API to deploy the HTTP challenge file.

.. code-block:: yaml

    {
        "username": "username",
        "password": "password",
        "challenges": [
            {
                "type": "http",
                "fileName": "u0I9eyI38aLP-xBs4x1TkYklr0hyvJ6RzWnwnIK2s",
                "content": "u0I9eyI38aLP-xBs4x1TkYklhyvJ6RzWnwu8nIK2s.yI3JvlzD374If-XdBCLA729aSeiJb7hqPqfd9PxG8"
            }
        ]
    }

.. note:: The use of an API to deploy automatically the HTTP challenge file to the web server is optional.
          The challenge file can be uploaded manually in the ``.well-known/acme-challenge`` folder in the web server.

Configured third-party certificate provider on BIG-IQ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Login to BIG-IQ as **david** by opening a browser and go to: ``https://10.1.1.4``.

Navigate to Configuration tab > Local Traffic > Certificate Management > Third Party CA Management.

Click **Create**.

- Name: ``demolab``
- CA Providers: ``Lets Encrypt``
- Server: ``https://acme-staging-v02.api.letsencrypt.org/``

Validate the server and accept the Terms and Conditions.

.. image:: ./media/img_module2_lab5-3.png
  :scale: 60%
  :align: center

2. Under Domain Configuration, click **Create**.

.. note:: Replace ``lab.webapp.34.219.3.233.nip.io`` and ``34.219.3.233`` with the correct wildcard DNS services 
          and demo web server public IP address in AWS.

- Domain Name: ``lab.webapp.34.219.3.233.nip.io``
- API End Point: ``http://lab.webapp.34.219.3.233.nip.io/hello``
- User Name: ``username``
- Password: ``password

Click **Deploy & Test**.

.. image:: ./media/img_module2_lab5-4.png
  :scale: 60%
  :align: center

3. While previous step is in progress, in your browser open ``http://lab.webapp.34.219.3.233.nip.io/hello``.

Notice a new HTTP challenge file has been added automatically.

.. image:: ./media/img_module2_lab5-5.png
  :scale: 60%
  :align: center


4. Download the HTTP challenge file and compare with previous value showing in the previous step.

.. image:: ./media/img_module2_lab5-6.png
  :scale: 60%
  :align: center

5. Wait until the Connection Status icon turns green and show Valid.

.. image:: ./media/img_module2_lab5-7.png
  :scale: 60%
  :align: center

SSL Certificate & Key creation on BIG-IQ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: ./media/img_module2_lab5-8.png
  :scale: 60%
  :align: center

.. image:: ./media/img_module2_lab5-9.png
  :scale: 60%
  :align: center

.. image:: ./media/img_module2_lab5-10.png
  :scale: 60%
  :align: center

.. image:: ./media/img_module2_lab5-11.png
  :scale: 60%
  :align: center

.. image:: ./media/img_module2_lab5-12.png
  :scale: 60%
  :align: center


AS3 HTTPS offload application service deployment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Go to the Applications tab > Applications and  click **Create** to create an Application Service:

.. note:: Replace ``lab.webapp.34.219.3.233.nip.io`` and ``34.219.3.233`` with the correct wildcard DNS services 
          and demo web server public IP address in AWS.

+---------------------------------------------------------------------------------------------------+
| Application properties:                                                                           |
+---------------------------------------------------------------------------------------------------+
| * Grouping = Part of an Existing Application                                                      |
| * Application Name = ``LAB_module2``                                                              |
+---------------------------------------------------------------------------------------------------+
| Select an Application Service Template:                                                           |
+---------------------------------------------------------------------------------------------------+
| * Template Type = Select ``AS3-F5-HTTPS-offload-lb-existing-cert-template-big-iq-default [AS3]``  |
+---------------------------------------------------------------------------------------------------+
| General Properties:                                                                               |
+---------------------------------------------------------------------------------------------------+
| * Application Service Name = ``https_app_service``                                                |
| * Target = ``SEA-vBIGIP01.termmarc.com``                                                          |
| * Tenant = ``tenant4``                                                                            |
+---------------------------------------------------------------------------------------------------+
| Analytics_Profile. Keep default.                                                                  |
+---------------------------------------------------------------------------------------------------+
| Pool                                                                                              |
+---------------------------------------------------------------------------------------------------+
| * Members: ``34.219.3.233``                                                                       |
+---------------------------------------------------------------------------------------------------+
| Service_HTTPS                                                                                     |
+---------------------------------------------------------------------------------------------------+
| * Virtual addresses: ``10.1.20.114``                                                              |
+---------------------------------------------------------------------------------------------------+
| Certificate. Keep default.                                                                        |
| * privateKey: ``/Common/lab.webapp.34.219.3.233.nip.io.key``                                      |
| * certificate: ``/Common/lab.webapp.34.219.3.233.nip.io.crt``                                     |
+---------------------------------------------------------------------------------------------------+
| TLS_Server. Keep default.                                                                         |
+---------------------------------------------------------------------------------------------------+

2. Check the application ``LAB_module2`` has been created along with the application service https_app_service

.. image:: ./media/img_module2_lab5-13.png
  :scale: 60%
  :align: center

.. note:: If not visible, refresh the page. It can take few seconds for the application service to appears on the dashboard.


3. SSH Ubuntu host in lab environment and add the domain name and Virtual address to the /etc/hosts file.

We are doing this to be able to use the domain name we used in the SSL certificate along with the Virtual IP address created in BIG-IP.
This is only for this lab.

.. code::

    f5student@ip-10-1-1-5:~$ sudo su -
    root@ip-10-1-1-5:/home/f5student# echo "10.1.10.114 lab.webapp.34.219.3.233.nip.io" >> /etc/hosts
    root@ip-10-1-1-5:/home/f5student# nslookup lab.webapp.34.219.3.233.nip.io


4. From the lab environment, launch a remote desktop session to have access to the Ubuntu Desktop. 
To do this, in your lab environment, click on the *Access* button
of the *Ubuntu Lamp Server* system and select *noVNC* or *xRDP*.

.. note:: Modern laptops with higher resolutions you might want to use 1440x900 and once XRDP is launched Zoom to 200%.

You can test the application service by opening a browser in the Ubuntu Jump-host and type the URL ``https://lab.webapp.34.219.3.233.nip.io``.

.. image:: ./media/img_module2_lab5-14.png
  :scale: 60%
  :align: center