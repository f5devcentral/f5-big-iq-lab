Class 6: BIG-IQ LTM Configuration Management
============================================

In this class, we will focus on LTM Configuration Management.

To learn more on `Application Delivery Controllers`_.

.. _Application Delivery Controllers: https://devcentral.f5.com/articles/what-is-an-application-delivery-controller-part-1-24742

.. toctree::
   :maxdepth: 1
   :glob:

   intro
   module*/module*

------------

The ``Configuration Tab`` in BIG-IQ.

.. image:: ./pictures/img_module1_1.png
  :align: center
  :scale: 50%

|

The ``Deployment Tab`` in BIG-IQ.

.. image:: ./pictures/img_module1_2.png
  :align: center
  :scale: 50%

|

**DEPLOYMENT TRACKING**

This area shows the last deployment for a device in a module area. 
Deployments are tracked separately from partial deployments.

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

------------

.. include:: ../lab.rst