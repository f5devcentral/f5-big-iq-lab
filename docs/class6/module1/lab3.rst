Lab 1.3: Renew expired certificates and deploy from BIG-IQ to managed BIG-IP
----------------------------------------------------------------------------

.. note:: Estimated time to complete: **5 minutes**

.. include:: /accesslab.rst

Tasks
^^^^^

We will now test how to renew an expired certificate on BIG-IQ, and push the renewed certificate & key pair to the managed BIG-IPs.

1. Login as **david** in BIG-IQ and navigate to **Configuration > LOCAL TRAFFIC > Certificate Management > Certificates & Keys**. 

   On this screen, you will see all the SSL certificates imported from BIG-IPs but not yet managed by BIG-IQ.

.. image:: media/img_module1_lab3-1.png
  :scale: 40%
  :align: center

2. Click on **Import**, then select *Import from BIG-IP Devices*.

webappLab2

- Key Password: ``Password@123456``