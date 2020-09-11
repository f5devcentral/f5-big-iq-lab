Class 4: BIG-IQ Platform
========================

Overview
^^^^^^^^

In this class, we will focus on the BIG-IQ CM and DCD.

**BIG-IQ CM**: Using BIG-IQ, you can centrally manage your BIG-IP devices, performing operations such as backups, 
licensing, monitoring, and configuration management. Because access to each area of BIG-IQ is role-based, 
you can limit access to users, thus maximizing work flows while minimizing errors and potential security issues.
BIG-IP device

**BIG-IQ DCD**: A data collection device (DCD) is a specially provisioned BIG-IQ system that you use to manage 
and store alerts, events, and statistical data from one or more BIG-IP systems.

Configuration tasks on the BIG-IP system determine when and how alerts or events are triggered. 
The alerts or events are sent to a BIG-IQ DCD, and the BIG-IQ retrieves them for your analysis. 
When you opt to collect statistical data from the BIG-IP devices, the DCD periodically (at an interval that you configure) 
retrieves those statistics from your devices, and then processes and stores that data.

The group of data collection devices that work together to store and manage your data are referred to as 
the data collection cluster. The individual data collection devices are generally referred to as nodes.

Modules/Labs
^^^^^^^^^^^^

.. toctree::
   :maxdepth: 1
   :glob:

   overview.rst
   module*/module*

