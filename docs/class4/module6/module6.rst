Module 6: BIG-IQ Zone Management
================================

**[New 6.1.0]** 

Since BIG-IQ 6.1, you can have **zones** for the Data Collection Devices, DCDs.
The zoning allows you to put BIG-IP devices and DCDs in close proximity to each other while the BIG-IQ management console is in another location.
The biggest reason for doing this is to avoid any issues relating to latency between the BIG-IP and DCDs.

All DCD’s CM’s form a single ES cluster, the Zone part is for BIG-IP’s to try to connect to a local DCD.
Replication within the ES cluster does not follow Zones.

.. note:: There can still be latency issues when using BIG-IQ management console to view statistical data as the queries
          for that data are done in real-time, which means they must traverse the network for both the query and the results.

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
