F5 BIG-IQ v6.1 and BIG-IP Cloud Edition
=======================================

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

There is lab environment available in UDF and Ravello (Oracle Public Cloud) for internal F5 users as well as Partners (please feel free to contact an `F5 representative`_).

.. _F5 representative: https://f5.com/products/how-to-buy#3013

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

- BIGIQ <> DCD 6.1.0
- 2x BIG-IP 13.1 / 1 cluster (BOS)
- 1x BIG-IP 14.1 / 1 standalone (SEA)
- 1x BIG-IP 12.1 / 1 standalone (SJC)
- LAMP Server - Radius, DHCP, RDP, Application Servers (Hackazon, dvmw, f5 demo app), Traffic Generator (HTTP, Access, DNS, Security).

**Components available**:

- "System" - Manage all aspects for BIG-IQ, 
- "Device"  - Discover, Import and manage BIGIP devices. 
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

.. warning:: When using the UDF or Ravello Lab, make sure:

   #. STOP the ESXi if you do not plan to demo VMware SSG.
   #. STOP your deployment at the end of your demo.
   #. Do not forget to tear down your AWS & Azure SSG if any.
   #. In case of demonstrating VMware SSG, use only Arizona, Virginia or Frankfurt region to get good performance.

.. warning:: The licenses used to license the BIG-IP and BIG-IQ are dev licenses and might need to be re-activated.

------------

**Documentations**:

- `BIG-IQ Knowledge Center`_
- `F5 BIG-IQ API`_
- `BIG-IP Cloud Edition FAQ`_
- `BIG-IP Cloud Edition Solution Guide`_
- `Light Product Demo`_ 
- `Troubleshoot Your Application Health and Performance with F5`_
- `AS3 Documentation`_
- `AS3 on GitHub`_

.. _BIG-IQ Knowledge Center: https://support.f5.com/csp/knowledge-center/software/BIG-IQ?module=BIG-IQ%20Centralized%20Management&version=6.0.1
.. _F5 BIG-IQ API: https://clouddocs.f5.com/products/big-iq/mgmt-api/latest/
.. _BIG-IP Cloud Edition FAQ: https://devcentral.f5.com/articles/big-ip-cloud-edition-faq-31270
.. _BIG-IP Cloud Edition Solution Guide: https://f5.com/resources/white-papers/big-ip-cloud-edition-solution-guide-31373
.. _Light Product Demo: http://engage.f5.com/BIG-IP-demo
.. _Troubleshoot Your Application Health and Performance with F5: https://interact.f5.com/troubleshooting-your-application-health-webinar.html
.. _AS3 Documentation: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/
.. _AS3 on GitHub: https://github.com/F5Networks/f5-appsvcs-extension

**Videos**:

- `Analytics in BIG-IP Cloud Edition`_
- `Deploying an Application with BIG-IP Cloud Edition`_
- `BIG-IP Cloud Edition Application Services Catalog`_
- `BIG-IP Cloud Edition Deploy and Secure an Application`_
- `BIG-IP Cloud Edition Auto-scaling with VMware`_
- `BIG-IP Cloud Edition Auto scaling with AWS`_
- `BIG-IP Cloud Edition Using the BIG IP Cloud Edition Dashboard`_

.. _Analytics in BIG-IP Cloud Edition: https://www.youtube.com/watch?v=6Oh6fBPLw6A
.. _Deploying an Application with BIG-IP Cloud Edition: https://www.youtube.com/watch?v=Qwr3RIfUobo
.. _BIG-IP Cloud Edition Application Services Catalog: https://www.youtube.com/watch?v=otH_YxdCly0
.. _BIG-IP Cloud Edition Deploy and Secure an Application: https://www.youtube.com/watch?v=0a5e-70vS-4
.. _BIG-IP Cloud Edition Auto-scaling with VMware: https://www.youtube.com/watch?v=fA22obOF_iY
.. _BIG-IP Cloud Edition Auto scaling with AWS: https://www.youtube.com/watch?v=YByW7Q3jAvQ
.. _BIG-IP Cloud Edition Auto scaling with Azure: https://youtu.be/dDWybCsQGgY
.. _BIG-IP Cloud Edition Using the BIG IP Cloud Edition Dashboard: https://www.youtube.com/watch?v=FjyJq_9NS2Y

**Tools**:

- `BIG-IP Cloud Edition trial on AWS and Azure`_
- `BIG-IQ PM team GitHub (various automation tools)`_

.. _BIG-IP Cloud Edition trial on AWS and Azure: https://github.com/f5devcentral/f5-big-ip-cloud-edition-trial-quick-start
.. _BIG-IQ PM team GitHub (various automation tools): https://github.com/f5devcentral/f5-big-iq-pm-team

------------

.. note:: A draft version of this lab guide can be found `here`_.

.. _here: https://f5-big-iq-lab.readthedocs.io/en/develop/