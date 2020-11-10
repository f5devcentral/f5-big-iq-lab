Lab 2.4: Delete AS3 Tenant/Applications on BIG-IQ
-------------------------------------------------

.. note:: Estimated time to complete: **5 minutes**

.. include:: /accesslab.rst

Task 9 - Delete Task1 with its AS3 application services
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Here, we empty the tenant/partition of Task1. This should remove those partitions from BOS-vBIGIP01.termmarc.com. The relevant Apps 
should also disappear from BIG-IQ. 

.. note:: We are not using the DELETE method but a POST with a declaration containing a tenant with nothing in it.

1. Open Google Chrome, then open the Postman extension and authenticate to BIG-IQ (follow |location_link_postman|).

.. |location_link_postman| raw:: html

   <a href="/training/community/big-iq-cloud-edition/html/postman.html" target="_blank">instructions</a>

2. The method and URL used will be ``POST https://10.1.1.4/mgmt/shared/appsvcs/declare``.
   Copy/Paste the AS3 declaration from the validator to the body in Postman.
   

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 15,16,17

   {
       "$schema": "https://raw.githubusercontent.com/F5Networks/f5-appsvcs-extension/master/schema/latest/as3-schema.json",
       "class": "AS3",
       "action": "deploy",
       "persist": true,
       "declaration": {
           "class": "ADC",
           "schemaVersion": "3.7.0",
           "id": "example-declaration-01",
           "label": "Task9",
           "remark": "Task 9 - Delete Tenants",
           "target": {
               "address": "10.1.1.8"
           },
           "Task1": {
               "class": "Tenant"
           }
       }
   }

3. Check the tenant/application(s) has been correctly removed from the BIG-IP and BIG-IQ.

.. warning:: Starting 7.0, BIG-IQ displays AS3 application services created using the AS3 Declare API as Unknown Applications.
             You can move those application services using the GUI, the `Move/Merge API`_, `bigiq_move_app_dashboard`_ F5 Ansible Galaxy role 
             or create it directly into Application in BIG-IQ using the `Deploy API`_ to define the BIG-IQ Application name.

.. _Move/Merge API: https://clouddocs.f5.com/products/big-iq/mgmt-api/latest/ApiReferences/bigiq_public_api_ref/r_as3_move_merge.html
.. _Deploy API: https://clouddocs.f5.com/products/big-iq/mgmt-api/latest/ApiReferences/bigiq_public_api_ref/r_as3_deploy.html
.. _bigiq_move_app_dashboard: https://galaxy.ansible.com/f5devcentral/bigiq_move_app_dashboard