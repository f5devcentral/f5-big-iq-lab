Class 5: BIG-IQ Device Management
=================================

In this class, we will focus on the BIG-IQ Device Management. Let's have a look at the ``Device Tab`` in BIG-IQ.

.. toctree::
   :maxdepth: 1
   :glob:

   intro
   module1/module1
   module2/module2
   module3/module3
   module4/module4
   module5/module5
   module6/module6
   module7/module7
   module8/module8
   module9/module9
   module10/module10
   module11/module11

------------

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

**BACKUPS & RESTORE**

- Talk about the ability to create scheduled or ad-hoc backups
- When creating a backup or backup schedule, you have the same options as you do when creating a backup on the BIG-IP (backup private keys and encrypt backup)
- The next section of the backup job specifies how long to retain a copy of the backup on the BIG-IQ:
- Never delete – retains the backup until someone specifically deletes it
- Delete the backup after N days - will delete the backup when that expiration date is reached
- Keep the last X backups – after the current backup completes, delete the oldest backup for this schedule
- Talk about the scheduling options
- Talk about the archive backup option – after a backup is brought to BIG-IQ, a copy of that backup can be archived off via SCP or SFTP to another server for DR or longer storage purposes.

**CONFIG TEMPLATES**

- Templates can be created and deployed to one or more devices to easily standardize settings for NTP, DNS, SMTP, and syslog settings.

**SCRIPT MANAGEMENT**

- Create and deploy/run scripts on the managed devices.  This area can be used for various purposes, including deploying or modifying BIG-IP configuration that is not natively manageable by the BIG-IQ or running a standard device startup/provisioning script prior to import into BIG-IQ.  Scripts can be bash or TMSH commands.

**LICENSE MANAGEMENT**

- BIG-IQ can manage licenses for up to 5000 BIG-IP VEs.  
- There are 3 ways that BIG-IQ can give a license to a BIG-IP
- Managed devices – If a device is already managed by BIG-IQ, you can select the device from a list
- Unmanaged devices – If you don’t want to manage the device with BIG-IQ, you just want to give it a license, you can specify IP, port, username, and password to push a license to a device
- Disconnected Devices - [NEW in 5.4] For situations where the BIG-IQ cannot talk directly to the BIG-IP, you can provide device MAC address and hypervisor information to BIG-IQ via the API and BIG-IQ will return a license that can be copied on to the box via some intermediary orchestrator.
- BIG-IQ can handle various types of pool licenses, including subscription and ELA pools, as well as allowing the customer to create their own pool of licenses out of individual VE keys. 

**PASSWORD MANAGEMENT**

- Manage the local root and admin passwords on the managed devices in bulk or individually. 

**SOFTWARE MANAGEMENT**

- Show that BIG-IQ can be a repository for all types of ISO images that F5 supplies: base images, hot-fix images, ENG-HF images.
- Select an image and click Managed Device Install. Discuss the different options:
- Preform pre and post installation assessment – BIG-IQ takes an inventory of things like virtual servers, pools, and pool members, along with their state and availability.  After the upgrade is complete, the same inventory is completed and if there are differences between the pre and post assessment, a list is provided of those differences.
- [NEW in 5.4] Perform backup – You can choose if you want BIG-IQ to take a backup before and/or after the upgrade is complete. 
- Pause after software copy – BIG-IQ copies the ISO or ISOs, in the case of a base and hotfix transfer, to the BIG-IP(s) and pauses to wait for an admin to click the button to continue the operation or cancel the job. BIG-IQ will only copy the images to the devices if they don’t already exist on the devices. 
- Pause for reboot confirmation – If this option is selected, the upgrade operation pauses right before the box is rebooted.
- Install devices one at a time – If this option is chosen, the upgrades will happen serially, as opposed to in parallel.
- Select devices and Target volume – Choose the devices you want to upgrade and select or create the target install volume.

**AUDIT LOGS**

The audit logs (in the Monitoring tab) show who made what change, when they made the change, the client IP that they logged in from to make the change, and what change did they make.  The changes can be exported to a text file or sent to a syslog server for external tracking.

**DASHBOARDS**

The dashboards (in the Monitoring tab) provide the visualization of the data that is collected on the BIG-IQ Data Collection Devices (DCDs).  This menu area will be blank if DCDs are not deployed or the statistics collection is failing.  

------------

.. include:: ../lab.rst