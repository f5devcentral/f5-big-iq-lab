Lab 7.1: VMWare BIG-IP VE Creation
----------------------------------

Prerequisites to this module:
  - None

1. Verify your BIG-IQ "Cloud Provider" for VMWare

Navigate to Applications > Environments > Cloud Providers

  |image02|

View the Cloud Provider object with your VMWare ephemeral account information.

  |image16|

2. Verify your BIG-IQ "Cloud Environment" for VMWare

Navigate to Applications > Environments > Cloud Environments

  |image03|

Settings for our already created Cloud Environment should be left unchanged.

  |image04|


Several parts of the Cloud Environment you may not want to be configured because you are planning on using F5 Declarative Onboarding. 
- Device Templates are used for Service Scaling Groups, not a single or cluster of BIG-IP.

3. Creating your BIG-IP in VMWare

Navigate to Devices > BIG-IP VE Creation > and choose **Create**

  |image05|

Fill in the Create BIG-IP VE Options.

.. Note:: You **MUST** accept the terms of the instance in VMWare before you can launch the image. Accept the EULA here_

+-------------------------------+---------------------------+
| BIG-IP VE Creation            |                           |
+===============================+===========================+
| Task Name                     | Deploy BIG-IP VE in VMWare|
+-------------------------------+---------------------------+
| BIG-IP VE Name                | bigipvm01                 |
+-------------------------------+---------------------------+
| Description                   | Created with BIG-IQ       |
+-------------------------------+---------------------------+
| Cloud Environment             | VMWare-environment        |
+-------------------------------+---------------------------+
| Address                       | DHCP                      |
+-------------------------------+---------------------------+
| Number of BIG-IP VE to Create | 1                         |
+-------------------------------+---------------------------+

Once all the attributes are configured **Create** the VE.

  |image06|

BIG-IQ will gather all the needed pieces from our Provider, Environment, and Creation options. These will be sent to the VMWare API for building out our instance.

  |image07|

By logging into the VMWare Console with your vSphere account, you can see the newly created instances. The address for MGMT was assigned with DHCP

.. Note:: vCenter credentials are Administrator@vsphere.local	/ Purpl3$lab

  |image08|

BIG-IP VE Creation is complete from here we can see BIG-IQ harvested the DHCP IP address.

  |image09|

Lab 2 of this module will cover Onboarding the newly created VMWare VE.


.. |image01| image:: pictures/image01.png
   :width: 75%
.. |image02| image:: pictures/image02.png
   :width: 50%
.. |image03| image:: pictures/image03.png
   :width: 85%
.. |image04| image:: pictures/image04.png
   :width: 75%
.. |image05| image:: pictures/image05.png
   :width: 50%
.. |image06| image:: pictures/image06.png
   :width: 50%
.. |image07| image:: pictures/image07.png
   :width: 90%
.. |image09| image:: pictures/image09.png
   :width: 50%

