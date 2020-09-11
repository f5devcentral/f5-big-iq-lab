F5 BIG-IQ Centralized Management Lab
====================================

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
Please reach out to your local **F5 Sales representative** if you are interested 
to **run one of the lab** or see a **demo**.

F5® BIG-IQ® is an end-to-end visibility, analytics, configuration, and management solution for F5 BIG-IP 
application delivery and security services and the devices that power them. BIG-IQ offers a unified 
platform to create, configure, provision, deploy, and manage F5 security and application delivery services. 

First of all, if you don't know what is BIG-IQ, watch the following video!

.. raw:: html

    <iframe width="560" height="315" src="https://www.youtube.com/embed/YZ6dZa512j8" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

|

Read |location_link_core_feature| and understand **Why should I use BIG-IQ?** and **What elements make up a BIG-IQ solution?**

.. |location_link_core_feature| raw:: html

   <a href="https://techdocs.f5.com/en-us/bigiq-7-1-0/big-iq-core-concepts/understanding-core-features-of-big-iq-centralized-management.html#ch-understanding-core-features-of-big-iq-centralized-management" target="_blank">Understanding Core Features of BIG-IQ Centralized Management</a>

Hands-On Labs
-------------

.. toctree::
   :maxdepth: 1
   :caption: Contents/Lab:
   :glob:

   startup.rst
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
   bigiqtestdrive.rst

Resources
---------

- `BIG-IQ Centralized Management for Complete Visibility and Control`_
- `BIG-IQ Knowledge Center`_
- `F5 BIG-IQ API`_
- `Light Product Demo`_ 
- `Troubleshoot Your Application Health and Performance with F5`_
- `AS3 Documentation`_
- `DO Documentation`_
- `BIG-IQ compatibility with Application Services 3 Extension and declarative onboarding`_
- `Free Training Courses - Getting Started with BIG-IQ Centralized Management`_

.. _BIG-IQ Centralized Management for Complete Visibility and Control: https://www.f5.com/products/automation-and-orchestration/big-iq
.. _BIG-IQ Knowledge Center: https://support.f5.com/csp/knowledge-center/software/BIG-IQ?module=BIG-IQ%20Centralized%20Management&version=7.1.0
.. _F5 BIG-IQ API: https://clouddocs.f5.com/products/big-iq/mgmt-api/latest/
.. _Light Product Demo: https://www.f5.com/products/automation-and-orchestration/big-iq/app-visibility-demo
.. _Troubleshoot Your Application Health and Performance with F5: https://interact.f5.com/troubleshooting-your-application-health-webinar.html
.. _AS3 Documentation: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/
.. _DO Documentation: https://clouddocs.f5.com/products/extensions/f5-declarative-onboarding/latest/
.. _BIG-IQ compatibility with Application Services 3 Extension and declarative onboarding: https://support.f5.com/csp/article/K54909607
.. _Free Training Courses - Getting Started with BIG-IQ Centralized Management: https://f5.com/education/training/free-courses/getting-started-with-big-iq

Videos
------

- `Look for the BIG-IQ videos on the YouTube DevCentral Channel`_

.. _Look for the BIG-IQ videos on the YouTube DevCentral Channel: https://www.youtube.com/playlist?list=PLyqga7AXMtPMw9ob6u73-anE6BWRsPhLr

Tools
-----

- BIG-IQ License Manager Public Cloud Template `AWS`_ and `Azure`_
- `BIG-IQ Trial on AWS and Azure`_
- `BIG-IQ Onboarding with Docker and Ansible`_
- `BIG-IQ PM team GitHub (various automation tools)`_


.. _AWS: https://github.com/F5Networks/f5-aws-cloudformation/tree/master/experimental/bigiq/licenseManagement
.. _Azure: https://github.com/F5Networks/f5-azure-arm-templates/tree/master/experimental/bigiq/licenseManagement
.. _BIG-IQ Trial on AWS and Azure: https://github.com/f5devcentral/f5-big-iq-trial-quick-start
.. _BIG-IQ PM team GitHub (various automation tools): https://github.com/f5devcentral/f5-big-iq-pm-team
.. _BIG-IQ Onboarding with Docker and Ansible: https://github.com/f5devcentral/f5-big-iq-onboarding
