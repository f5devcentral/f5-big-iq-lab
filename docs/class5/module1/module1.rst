Module 1: BIG-IP devices management and inventory
=================================================

To start managing a BIG-IP® device, you must add it to the BIG-IP Devices inventory list on the BIG-IQ® system.

Adding a device to the BIG-IP Devices inventory is a two-stage process.

**Stage 1:**

-  You enter the IP address, port (if other than default), and credentials of the BIG-IP device you're adding, and associate it with a cluster (if applicable).
-  BIG-IQ opens communication (establishes trust) with the BIG-IP device.
-  BIG-IQ discovers the current configuration for any selected services you specified are licensed on the BIG-IP system, like LTM® (optional).

**Stage 2:**

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

     - The BIG-IP device must be located in your network or reachable from BIG-IQ.
     - The BIG-IP device must be running a compatible software version. see `K34133507 <https://support.f5.com/csp/article/K34133507>`_.
     - Port 22 and 443 must be open to the BIG-IQ management address, or any alternative IP address used to add the BIG-IP device to the BIG-IQ inventory.


.. toctree::
   :maxdepth: 1
   :glob:

   lab*


**BIG-IP DEVICES**

- Discuss the data shown in the table for each device: hostname, IP address, services managed
- Discuss the ability to export a CSV file of the device inventory, point out additional information is included in that inventory: license key, license file, etc
- Click the More button to show additional tasks that can be launched for each device from this menu.
- Click on a device name and show the properties shown for each device

**BIG-IP CLUSTERS**

- Show the DSC cluster sync status is available
- Drill down on a cluster and click the traffic group tab to show active vs standby
- Show the DNS sync group information is available
- Talk about how this is multiple commands run on each BIG-IP device and manual correlation without BIG-IQ.

**DEVICE GROUPS**

- Talk about the ability to create static and dynamic device groups
- Static groups require you to choose each device that you want to include in the group
- Dynamic groups allow you to specify a root group and a search term.  When devices match this search term, they are automatically added to the group.  For example, if the device host names have an indication of what datacenter they are installed it, you can create a dynamic group to manage things like backups to happen at the same time.  As new devices are added that match the term, they would automatically be backed up by the backup schedule that references this dynamic group.
- Groups can be scoped for use in particular areas of the product, so if you have groups that only apply to the Web Application Security configuration, you can make sure that those groups don’t appear for selection in things like device backups.
