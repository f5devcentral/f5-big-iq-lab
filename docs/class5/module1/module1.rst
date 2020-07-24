Module 1: BIG-IP devices management and inventory
=================================================

To start managing a BIG-IP® device, you must add it to the BIG-IP Devices inventory list on the BIG-IQ® system.

Adding a device to the BIG-IP Devices inventory is a two-stage process.

Stage 1:

-  You enter the IP address, port (if other than default), and credentials of the BIG-IP device you're adding, and associate it with a cluster (if applicable).

-  BIG-IQ opens communication (establishes trust) with the BIG-IP device.

-  BIG-IQ discovers the current configuration for any selected services you specified are licensed on the BIG-IP system, like LTM® (optional).

Stage 2:

-  BIG-IQ imports the licensed services configuration you selected in stage 1 (optional).

The basic discovery allows for device inventory, device health
monitoring, backup and restore of the managed device, integration with
F5’s iHealth service, software upgrade, and device template deployment.
As part of the discovery process, you can choose to manage other parts
of the BIG-IP configuration.

In this scenario, we will import a BIG-IP device and associate it with
an existing Cluster, review the device information available in BIG-IQ,
export our inventory to a CSV file, and review the inventory.

.. note::
     Be aware of the following dependencies when adding a BIG-IP device to BIG-IQ CM

     1.	The BIG-IP device must be located in your network or reachable from BIG-IQ.
     2.	The BIG-IP device must be running a compatible software version [K34133507](https://support.f5.com/csp/article/K34133507).
     3.	Port 22 and 443 must be open to the BIG-IQ management address, or any alternative IP address used to add the BIG-IP device to the BIG-IQ inventory.


.. toctree::
   :maxdepth: 1
   :glob:

   lab*