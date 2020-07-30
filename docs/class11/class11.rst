Class 11: BIG-IQ DDoS Monitoring and Dashboard
==============================================

Overview
^^^^^^^^

In this class, we will review new DDoS Dashboard view, protection summary, and DDoS Event logging and correlation. 

We will cover BIG-IQ DDoS Monitoring and Dashboard. 
Components used include BIG-IP CM/DCD along with the BOS and SJC BIG-IPs and Ubuntu host. 
SEA BIG-IPs can be stopped.

For simplicity, UDP attack traffic will be generated against both DNS virtual servers and device wide DoS: 
additional attacks can be done using the client nodes at the discretion of the student. 

At a minimum, this class only requires the two BOS BIG-IPs, the SJC BIG-IP, BIG-IQ CM and DCD, and the LAMP server. 

The DNS Virtual Server 10.1.10.203 is already created and will be used as an attacked destination in these labs.

Labs
^^^^

.. toctree::
   :maxdepth: 1
   :glob:

   module*/module*

------------

.. include:: ../lab.rst