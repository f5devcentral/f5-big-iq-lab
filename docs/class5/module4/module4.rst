Module 4: Partial Deployment & Partial Restore
==============================================

In this lab, we will demonstrate how to partially deploy the changes made to the device specific objects to the managed BIG-IP devices.

This figure illustrates the workflow you perform to manage the objects on BIG-IP devices. 

|image01|

Deploying changes applies the revisions that you have made on the BIG-IQ® Centralized Management system to the managed BIG-IP® devices.

The objects that you manage using BIG-IQ® depend on associations with other, supporting objects. These objects are called \ ***shared objects***.

When the BIG-IQ evaluates a deployment to a managed device, it starts by deploying the device-specific objects. Then it examines the managed
device to compile a list of the objects that are needed by other objects on that device. Then (based on the recent analysis) the BIG-IQ deletes
any shared objects that exist on the managed device but are not used. So if there are objects on a managed device that are not being used, the
next time you deploy changes to that device, the unused objects are deleted.

You have the option to choose whether you want to evaluate all of the changes, or specify which changes to evaluate. Select either \ **All Changes** or **Partial Changes** from the selected source.

.. note:: When BIG-IQ® Centralized Management evaluates configuration changes, it first re-discovers the configuration from the managed device to ensure that there are no unexpected differences. If there are issues, the default behavior is to discard any changes made on the managed device, and then deploy the configuration changes.

- To accept the default, proceed with the evaluation. The settings from the managing BIG-IQ overwrite the settings on the managed BIG-IP® device.
- To override the default, re-discover the device and re-import the service. The settings from the managed BIG-IP device overwrite any changes that have been made using the BIG-IQ.


.. toctree::
   :maxdepth: 1
   :glob:

   lab*

.. |image01| image:: media/image1.png
