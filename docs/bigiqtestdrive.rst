BIG-IQ Test Drive Labs
======================

Welcome
-------

Welcome to the **F5 BIG-IQ Test Drive**.

This lab provides hands-on experience using F5's BIG-IQ.

BIG-IQ allows you to take an **application-centric** approach to core IT, networking, services provisioning, 
and deployment with a unified tool for gaining visibility into and managing your F5 application delivery and security portfolio.

BIG-IQ significantly extends the operability and value of your F5 investment. From a single console, 
BIG-IQ offers users the ability to create, configure, deploy, analyze, troubleshoot, patch, and upgrade 
F5 **security** and **application delivery services**. BIG-IQ also supports holistic device management of 
F5 BIG-IP™ **physical and virtual devices** both locally and in the cloud.

From per-app virtual editions to traditional hardware appliances, BIG-IQ makes it possible to gain visibility 
into apps and devices, leverage **automated workflows**, simplify configuration, and ensure every team—and every 
app—has the resources required to perform optimally. 

With BIG-IQ you can quickly and easily manage, analyze, and troubleshoot every device, every application, and 
every policy from one **centralized** location—no matter the operating environment.

New to BIG-IQ? Get started by watching the video below.

.. raw:: html

   <iframe width="560" height="315" src="https://www.youtube.com/embed/QAPeSOd7O40" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

|

.. raw:: html

    <iframe width="560" height="315" src="https://www.youtube.com/embed/YZ6dZa512j8" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

|

Understand the |location_link_core_feature|.

.. |location_link_core_feature| raw:: html

   <a href="https://techdocs.f5.com/en-us/bigiq-7-1-0/big-iq-core-concepts/understanding-core-features-of-big-iq-centralized-management.html#ch-understanding-core-features-of-big-iq-centralized-management" target="_blank">Core Features of BIG-IQ Centralized Management</a>

**This lab will cover the following topics:**

- Managing application services with legacy and Application Services 3 Extension (AS3) templates
- Troubleshooting and assessing health and performance at-a-glance with application-specific dashboards
- Keeping certificates compliant and up-to-date with integrated certificate management workflows
- Backing-up, patching, and orchestrating upgrades of BIG-IP devices

**Optional labs:**

- Using BIG-IQ with Venafi, leader in X.509 certificate management
- Building advanced, DevOps-aligned automation workflows with BIG-IQ, GitLab, and Ansible configuration management
- Solving common challenges associated with importing legacy BIG-IPs into BIG-IQ

Once you are ready to start your BIG-IQ journey, consult the |location_link_getstarted2| page, then start with *BIG-IQ Application Management and AS3* Hands-On Labs.

.. |location_link_getstarted2| raw:: html

   <a href="/training/community/big-iq-cloud-edition/html/startup.html" target="_blank">Getting Started</a>

.. note:: Labs below are part of a larger BIG-IQ lab guide. The labs on the BIG-IQ Test Drive page need to be done as listed.

Hands-On Labs
-------------

**BIG-IQ Application Management and AS3** *(Estimated time to complete: 40min)*

.. toctree::
   :maxdepth: 1
   :glob:

   class1/module3/lab1
   class1/module3/lab2
   class1/module3/lab3
   class1/module6/lab1
   class1/module6/lab2
   class1/module6/lab3

**BIG-IQ Analytics** *(Estimated time to complete: 30min)*

.. toctree::
   :maxdepth: 1
   :glob:

   class3/module1/module1
   class3/module2/lab1
   class3/module2/lab2
   class3/module2/lab3
   class3/module4/lab1

**BIG-IQ LTM Configuration Management** *(Estimated time to complete: 20min)*

.. toctree::
   :maxdepth: 1
   :glob:

   class6/module1/lab1
   class6/module1/lab2
   class6/module1/lab3

**BIG-IQ Device Management** *(Estimated time to complete: 30min)*

.. toctree::
   :maxdepth: 1
   :glob:

   class5/module3/lab1
   class5/module3/lab2
   class5/module1/lab6
   class5/module1/lab7

Optional Hands-On Labs
----------------------

.. warning:: Start the **Venafi Trust Protection server** in the UDF environment in order to complete **Lab 1.4** and 
             follow instructions on the Getting Started page to generate a SSH keys for **Lab 2.12** and **2.13**.

.. toctree::
   :maxdepth: 1
   :glob:

   class6/module1/lab4
   class1/module2/lab12
   class6/module5/module5.rst
   class1/module2/lab13

Resources
---------

- `BIG-IQ Centralized Management for Complete Visibility and Control`_
- `BIG-IQ Knowledge Center`_
- `Glossary`_

.. _BIG-IQ Centralized Management for Complete Visibility and Control: https://www.f5.com/products/automation-and-orchestration/big-iq
.. _BIG-IQ Knowledge Center: https://support.f5.com/csp/knowledge-center/software/BIG-IQ?module=BIG-IQ%20Centralized%20Management&version=7.1.0
.. _Glossary: https://www.f5.com/services/resources/glossary