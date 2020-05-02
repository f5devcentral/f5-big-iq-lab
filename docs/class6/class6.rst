Class 6: BIG-IQ LTM Configuration Management
============================================

In this class, we will focus on LTM Configuration Management.

To learn more on application delivery controllers, - `DevCentral`_.

.. _DevCentral: https://devcentral.f5.com/articles/what-is-an-application-delivery-controller-part-1-24742

.. toctree::
   :maxdepth: 1
   :glob:

   intro
   module*/module*

------------

Let's have a look at the ``Configuration Tab`` in BIG-IQ.

.. image:: ./pictures/img_module1_1.png
  :align: center
  :scale: 50%

|

**LOCAL TRAFFIC**

  -	Click on the virtual server menu.  Show the state and availability.  Show the ability to sort the column in the table.  Show the ability to search and filter the table.
  -	Click on a virtual server that is installed on the clustered BIG-IPs (01 and 02), like the HR virtual server.  Point out that the editing view is very similar to the view on the BIG-IP.  Change something like the port and save the change.  Point out that BIG-IQ has updated the staged configuration for the virtual server on both cluster devices.
  -	Show the ability to clone a virtual server to create one that is very similar to an existing one.  Cloned virtuals can be created on the same device/cluster or on a different device/cluster.  Note: with the service template feature, this feature may become less used/useful, as this only clones the virtual, not all of the application components.
  -	Show the ability to bulk attach iRules.
  -	Show the ability to select one or more virtuals and create a partial deployment.
  -	Show the ability to edit iRules.  BIG-IQ does not do any context checking, but depending on the browser, you might see some editing assistance.
  -	Review the rest of the LTM components

  - Click on the certificate management area
  
    - Click on Certs and Keys: This is where we can manage traffic certs to be used in SSL profiles.
    - Create button allows you to create self-signed certs or create a CSR to send off to a CA for a signed cert.
    - After you receive the signed cert, you can click the Import button to import the cert, key, or PKCS#12 bundle.
    - The generate report button exports a CSV file of all of the metadata about the certs that are on the BIG-IQ.
    - The Alert Settings button takes you to the page to configure the alerts about certificate expiration.

      - The currently available alerts are N days ahead of certificate expiration and an alert that the certificates has expired.
      - These alerts are currently send via email only.

  - The More button exposed additional options to clone or delete a certificate.
  - The status column in the table gives a visual indication if the cert has expired, will expire soon, or if the expiration is significantly in the future (beyond the alert threshold that is set for N days alert)
  -	The state column indicates if the actual cert and key exist on the BIG-IQ or just the metadata.  Only the metadata can be discovered/imported from the BIG-IP, as there is no REST interface on the BIG-IP to pull the full cert and key at this time.  Certs and keys create or imported on BIG-IQ will show a “Managed” state and discovered certs will show an Unmanaged state until someone manually exports the cert and key from the BIG-IP GUI (save file or copy and paste).  You can accomplish this by clicking on the name of an unmanaged cert and importing the cert and key.
  - If you click on the name of a cert that is Managed, you can renew the cert using the button in the upper right.  For self-signed certs, you are presented the self-signed cert page and for CA signed certs, you are brought to a CSR page.  You can change a cert from self-signed to CA signed here as well.
  - Click on the row (not the name) for the “ f5test.com_self-signed_2015” cert.  The preview pane pops up at the bottom left and the bottom right allows you to show the items/objects related to this object. Click the Show button, to reveal the related items.  Anything that shows as a link will take you to the configuration page for that object.
  - Click on Certificate Revocation Lists – This is where you can import CRLs from a BIG-IP.

- Click on Eviction Policies – this is where you can configure Eviction Policies for use in various modules.
- General Settings – This is where you can associate an Eviction Policy with a device, as well as set the Default Per VS SYN Check Threshold, Global SYN Check Threshold, and Enable Hardware VLAN SYN Cookie Protection.
- Logs – This is where you can configure Log Filters, Log Publishers, and Log Destinations.  Some of these were available in Shared Security in prior releases, but have been moved to the LTM area in 5.4.
- Pinning Policies – This is where you can manage what objects are pinned to a device for LTM.  Objects that are pinned will be pushed to a device or will remain installed on a device, even if they are not used/referenced in the configuration for that device.



Let's have a look at the ``Deployment Tab`` in BIG-IQ.

.. image:: ./pictures/img_module1_2.png
  :align: center
  :scale: 50%

|

**DEPLOYMENT TRACKING**

This area shows the last deployment for a device in a module area.  Deployments are tracked separately from partial deployments.

**EVALUATE AND DEPLOY**

This is the area where changes are deployed from the BIG-IQ to the BIG-IP.  This area is also broken out by module area.  This change process is defined in 2 parts: evaluate and deploy.  During the evaluate process, the REST API is used to pull the latest configuration from the BIG-IP(s) that are involved and compare that configuration to a snapshot of the BIG-IQ configuration.  The output of this evaluation is presented to the user to review the diff of the changes that were discovered as part of the evaluation process.  BIG-IQ also evaluates the configuration for verification warnings or critical errors.  Verification warnings are things that might cause configuration issues, like a log profile not being attached to a virtual, but they do not block the deployment.  Critical errors are issues that will cause issues or fail the deployment, like a VLAN that is referenced doesn’t exist on the device, and BIG-IQ will not allow you to deploy these changes until the configuration is fixed.
The “Source” for the evaluation can be done against the “Current Changes” that are staged in the BIG-IQ configuration or against an “Existing Snapshot.”  Deployments from an “Existing Snapshot” allow you to rollback configuration, or part of the configuration, for a module area to a prior point in time.
Evaluations can be “scoped” against the entire configuration “All Changes” or a subset of the configuration “Partial Changes.”  If you choose “All Changes” BIG-IQ is going to evaluate differences for the entire configuration that BIG-IQ can manage for the module area for the selected BIG-IP devices. In 5.4 and above, when you choose “All Changes” you are also asked if you want to “Remove unused objects” or “Keep unused objects.”  An unused object is an object that is not referenced by another object in the BIG-IP configuration. If you choose to “remove unused objects,” the BIG-IQ will delete the objects from the BIG-IP configuration, while retaining them on the BIG-IQ.  If you choose “Partial Changes,” you select the specific objects that you want to evaluate for changes.  As part of this selection, you get to choose if you want to include supporting objects as part of the evaluation.  An example of a supporting object is the profile that is referenced by a virtual server.  If you select a virtual server and select to include supporting objects, the associated profile will also be evaluated.
Once the evaluation step is complete, you can review the differences, to make sure the changes that have been detected are the changes that you want to make.  Finally, you can deploy the changes at that point, schedule the changes to happen later, or leave the evaluation for deployment at a later time by you or someone else with the deployment privilege.  
You can choose to create a deployment directly as well.  It will still go through the evaluate process, but will allow you to deploy in a single step.  The downside is that you don’t get a chance to review the differences before the deployment happens.

**SNAPSHOTS**

This area allows you to manage and compare the snapshots created by the BIG-IQ system.  Snapshots are automatically created by the evaluation and deployment process described above, but they can be created as part of configuration import or in an ad-hoc manner in this area.  These snapshots are a reference to the versions of the objects that are stored in the BIG-IQ database at the time the snapshot is taken.  You can compare two snapshots to see what differences there are between the two points in time the snapshots were taken.  The snapshots can be used as part of a deployment activity to roll back the configuration of an object or objects to a prior version and they can also be used to roll back the BIG-IQ configuration to a prior point in time.

**RESTORE**

The restore area allows you to restore all or part of the BIG-IQ configuration to a prior point in time.

**QUICK UPDATES**
This area shows the list enable, disable, and force offline activities that have been launched by users.  These activities can be launched directly from the configuration area for virtual servers and pool members, by users with the right privileges.

