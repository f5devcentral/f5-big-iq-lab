F5 BIG-IQ and BIG-IP Cloud Edition
==================================

Welcome
-------

Welcome to the |classbold| - |year|

|repoinfo|

This document details the lab exercises and demonstrations that comprise
the hands-on component of the BIG-IQ. The environment is setup with
basic configuration and associated traffic generation to populate
dashboards for easy demos. Additional configuration can be added to
support items that are not currently covered.

This lab environment is designed to allow for quick and easy demos of a
significant portion of the BIG-IQ product. The Linux box in the
environment has multiple cron jobs that are generating traffic that
populates the Monitoring tab and Application dashboard.

This lab environment is available for internal F5 users.

.. toctree::
   :maxdepth: 1
   :caption: Contents/Lab:
   :glob:

   class1/class1
   class2/class2
   class3/class3
   class4/class4
   class5/class5
   class6/class6
   class7/class7
   class8/class8
   class9/class9
   class10/class10
   class11/class11
   class12/class12

------------

.. image:: ./pictures/diagram_udf.png
   :align: center
   :scale: 60%

**Networks**:

- 10.1.1.0/24 lab environment Management Network
- 10.1.10.0/24 lab environment External Network
- 10.1.20.0/24 lab environment Internal Network
- 10.1.30.0/24 lab environment SSLo Inline L2 IN Network
- 10.1.40.0/24 lab environment SSLo Inline L2 OUT Network
- 10.1.50.0/24 lab environment SSLo TAP Network
- 172.17.0.0/16 lab environment Docker Internal Network
- 172.100.0.0/16 AWS Internal Network
- 172.200.0.0/16 Azure Internal Network

**List of instances**:

- BIG-IQ <> DCD 7.0.0.1
- 2x BIG-IP 13.1 / 1 cluster (BOS)
- 2x BIG-IP 14.1 / 1 standalone (SEA) and 1 standalone (PARIS)
- 1x BIG-IP 12.1 / 1 standalone (SJC)
- LAMP Server - Radius, LDAP, DHCP, xRDP, noVNC, Splunk, Application Servers (Hackazon, dvmw, f5 demo app), Traffic Generator (HTTP, Access, DNS, Security), Samba, AWX/Ansible Tower.
- SSLo Service TAP and L2 (only with lab environment Ravello)
- ESXi 6.5.0 + vCenter (only with lab environment Ravello)

**Components available**:

- "System" - Manage all aspects for BIG-IQ, 
- "Devices" - Discover, Import, Create, Onboard (DO) and Manage BIG-IP devices.
- "Configuration" - ADC, Security (ASM, AFM, APM, DDOS, SSLo config/monitoring)
- "Deployment" - Manage evaluation task and deployment.
- "Monitoring" - Event collection per device, statistics monitoring, iHealth reporting integration, alerting, and audit logging.
- "Applications" - Application Management (Cloud Edition, AS3) and Service Scaling Group

------------

**Documentations**:

- `BIG-IQ Knowledge Center`_
- `F5 BIG-IQ API`_
- `BIG-IP Cloud Edition FAQ`_
- `BIG-IP Cloud Edition Solution Guide`_
- `Light Product Demo`_ 
- `Troubleshoot Your Application Health and Performance with F5`_
- `AS3 Documentation`_
- `DO Documentation`_
- `BIG-IQ compatibility with Application Services 3 Extension and declarative onboarding`_
- `Free Training Courses - Getting Started with BIG-IQ Centralized Management`_

.. _BIG-IQ Knowledge Center: https://support.f5.com/csp/knowledge-center/software/BIG-IQ?module=BIG-IQ%20Centralized%20Management&version=7.0.0
.. _F5 BIG-IQ API: https://clouddocs.f5.com/products/big-iq/mgmt-api/latest/
.. _BIG-IP Cloud Edition FAQ: https://devcentral.f5.com/articles/big-ip-cloud-edition-faq-31270
.. _BIG-IP Cloud Edition Solution Guide: https://f5.com/resources/white-papers/big-ip-cloud-edition-solution-guide-31373
.. _Light Product Demo: http://engage.f5.com/BIG-IP-demo
.. _Troubleshoot Your Application Health and Performance with F5: https://interact.f5.com/troubleshooting-your-application-health-webinar.html
.. _AS3 Documentation: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/
.. _DO Documentation: https://clouddocs.f5.com/products/extensions/f5-declarative-onboarding/latest/
.. _BIG-IQ compatibility with Application Services 3 Extension and declarative onboarding: https://support.f5.com/csp/article/K54909607
.. _Free Training Courses - Getting Started with BIG-IQ Centralized Management: https://f5.com/education/training/free-courses/getting-started-with-big-iq

------------

**Videos**:

- `Look for the BIG-IQ videos on the YouTube DevCentral Channel`_

.. _Look for the BIG-IQ videos on the YouTube DevCentral Channel: https://www.youtube.com/user/devcentral/search?query=BIG-IQ

------------

**Tools**:

- BIG-IQ License Manager Public Cloud Template `AWS`_ and `Azure`_
- `BIG-IQ Trial on AWS and Azure`_
- `BIG-IP Cloud Edition Trial on AWS and Azure`_
- `BIG-IQ Onboarding with Docker and Ansible`_
- `BIG-IQ PM team GitHub (various automation tools)`_


.. _AWS: https://github.com/F5Networks/f5-aws-cloudformation/tree/master/experimental/bigiq/licenseManagement
.. _Azure: https://github.com/F5Networks/f5-azure-arm-templates/tree/master/experimental/bigiq/licenseManagement
.. _BIG-IQ Trial on AWS and Azure: https://github.com/f5devcentral/f5-big-iq-trial-quick-start
.. _BIG-IP Cloud Edition Trial on AWS and Azure: https://github.com/f5devcentral/f5-big-ip-cloud-edition-trial-quick-start
.. _BIG-IQ PM team GitHub (various automation tools): https://github.com/f5devcentral/f5-big-iq-pm-team
.. _BIG-IQ Onboarding with Docker and Ansible: https://github.com/f5devcentral/f5-big-iq-onboarding
