Lab 8.1: Prepare your AWS Account 
---------------------------------

.. warning:: If you already created an AWS Application in Class 2 (AWS SSG), you do not need to recreate this item.

1. Create the AWS environment and VPN

SSH Ubuntu host in UDF:

.. image:: pictures/image22.png
  :align: left
  :scale: 80%

Navigate to: ``cd f5-aws-vpn-ssg``

Execute the Ansible scripts to create the VPN 

``./000-RUN_ALL.sh ve``

.. note:: VPN object and servers can take up to 45 minutes to complete.

The console will output your ephemeral credentials for the resources created, ** yours will be different88. Save these for later use.

 |image01|

.. |image01| image:: pictures/image1.png
   :width: 100%