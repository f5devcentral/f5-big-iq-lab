Class 11: BIG-IQ DDoS Monitoring and Dashboard
==============================================

In this class, we will review new DDoS Dashboard view, protection summary, and DDoS Event logging and correlation. 

.. toctree::
   :maxdepth: 1
   :glob:

   intro
   module*/module*
   
------------

For simplicity, UDP attack traffic will be generated against both DNS virtual servers and device wide DoS: 
additional attacks can be done using the client nodes at the discretion of the student. 

ESXi is not required for this class and can be shutdown.

At a minimum, this class only requires the two BOS BIG-IPs, the SJC BIG-IP, BIG-IQ CM and DCD, and the LAMP server. 

The DNS Virtual Server 10.1.10.203 is already created and will be used as an attacked destination in these labs.

------------

.. include:: ../lab.rst