Module 4: BIG-IQ HA
===================

Setting up BIG-IQ® in a high availability configuration ensures that you always have access to the BIG-IP® devices you are managing.

In a BIG-IQ high availability configuration, the BIG-IQ system replicates configuration changes since the last synchronization from the primary
device to the secondary device every 30 seconds.

If it ever becomes necessary, you can have the secondary peer take over management of the BIG-IP devices.

**Automatic failover for high availability**:
- Configure BIG-IQ to automatically fail over to the standby BIG-IQ in the event communication is lost or in the unlikely event the active BIG-IQ fails. 
- No further intervention is required during a failover event following initial BIG-IQ auto-failover configuration. 

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
