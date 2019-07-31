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
populates the monitoring tab.

This lab environment is available in UDF for internal F5 users as well as Partners (please feel free to contact an `F5 representative`_).

.. _F5 representative: https://f5.com/products/how-to-buy

.. image:: ./pictures/diagram_udf.png
   :align: center
   :scale: 50%

**Networks**:

- 10.1.1.0/24 UDF Management Network
- 10.1.10.0/24 UDF External Network
- 10.1.20.0/24 UDF Internal Network
- 172.17.0.0/16 UDF Docker Internal Network
- 172.100.0.0/16 AWS Internal Network
- 172.200.0.0/16 Azure Internal Network

**List of instances**:

- BIG-IQ <> DCD 7.0.0
- 2x BIG-IP 13.1 / 1 cluster (BOS)
- 1x BIG-IP 14.1 / 1 standalone (SEA)
- 1x BIG-IP 12.1 / 1 standalone (SJC)
- LAMP Server - Radius, LDAP, DHCP, RDP, Application Servers (Hackazon, dvmw, f5 demo app), Traffic Generator (HTTP, Access, DNS, Security).

**Components available**:

- "System" - Manage all aspects for BIG-IQ, 
- "Device"  - Discover, Import, Create, Onboard and manage BIGIP devices. 
- "Configuration" - ADC, Security (ASM config/monitoring, AFM config, FPS monitoring.)
- "Deployment" - Manage evaluation task and deployment.
- "Monitoring" - Event collection per device, statistics monitoring, iHealth reporting integration, alerting, and audit logging.
- "Application" - Application Management (Cloud Edition, AS3)

------------

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

------------

.. warning:: When using the UDF, make sure:

   #. STOP your deployment at the end of your demo.
   #. Do not forget to tear down your AWS & Azure SSG or VE(s) if any.
   #. In case of demonstrating VMware SSG, use only Arizona, Virginia or Frankfurt region to get good performance.

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

.. _BIG-IQ Knowledge Center: https://support.f5.com/csp/knowledge-center/software/BIG-IQ?module=BIG-IQ%20Centralized%20Management&version=6.0.1
.. _F5 BIG-IQ API: https://clouddocs.f5.com/products/big-iq/mgmt-api/latest/
.. _BIG-IP Cloud Edition FAQ: https://devcentral.f5.com/articles/big-ip-cloud-edition-faq-31270
.. _BIG-IP Cloud Edition Solution Guide: https://f5.com/resources/white-papers/big-ip-cloud-edition-solution-guide-31373
.. _Light Product Demo: http://engage.f5.com/BIG-IP-demo
.. _Troubleshoot Your Application Health and Performance with F5: https://interact.f5.com/troubleshooting-your-application-health-webinar.html
.. _AS3 Documentation: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/
.. _DO Documentation: https://clouddocs.f5.com/products/extensions/f5-declarative-onboarding/latest/

**Videos**:

- `Look for the BIG-IQ videos on the YouTube DevCentral Channel`_

.. _Look for the BIG-IQ videos on the YouTube DevCentral Channel: https://www.youtube.com/user/devcentral/videos

**Tools**:

- `BIG-IP Cloud Edition trial on AWS and Azure`_
- `BIG-IQ PM team GitHub (various automation tools)`_
- `BIG-IQ Onboarding with Docker and Ansible`_

.. _BIG-IP Cloud Edition trial on AWS and Azure: https://github.com/f5devcentral/f5-big-ip-cloud-edition-trial-quick-start
.. _BIG-IQ PM team GitHub (various automation tools): https://github.com/f5devcentral/f5-big-iq-pm-team
.. _BIG-IQ Onboarding with Docker and Ansible: https://github.com/f5devcentral/f5-big-iq-onboarding

------------
