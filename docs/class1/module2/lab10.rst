Lab 2.10: Moving existing AS3 Application Services from BIG-IP to BIG-IQ
------------------------------------------------------------------------

.. note:: Estimated time to complete: **5 minutes**

In this lab, we are going to see the process to move AS3 Application Services already 
deployed directly on BIG-IP using the API on BIG-IQ.

The process consist simply to add the target property under the ADC class in the 
AS3 declaration and re-send the full declaration to the BIG-IQ declare or deploy-to-application APIs.

.. include:: /accesslab.rst

Deploy AS3 Application Service directly to the BIG-IP
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This declaration will create an HTTP application on BIG-IQ using an HTTP template. 
This declaration abstracts the complexity of having to configure all the HTTP defaults such as cookies, persistence, etc...

1. Copy below example of an AS3 Declaration into the IDE (Integrated development environment) available within the lab environment, 
   click on the *Access* button of the *Ubuntu Lamp Server* system and select *Visual Studio Code*.

   .. note:: It is recommended to `validate your AS3 declaration`_ against the schema using Microsoft Visual Studio Code.

   .. _validate your AS3 declaration: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/userguide/validate.html
   
.. code-block:: yaml
   :linenos:
   :emphasize-lines: 13,29,45,46

   {
       "$schema": "https://raw.githubusercontent.com/F5Networks/f5-appsvcs-extension/master/schema/latest/as3-schema.json",
       "class": "AS3",
       "action": "deploy",
       "persist": true,
       "declaration": {
           "class": "ADC",
           "schemaVersion": "3.7.0",
           "id": "example-declaration-01",
           "label": "Task1",
           "remark": "Task 1 - HTTP Application Service",
           "Task1": {
               "class": "Tenant",
               "MyWebApp1http": {
                   "class": "Application",
                   "template": "http",
                   "statsProfile": {
                       "class": "Analytics_Profile",
                       "collectClientSideStatistics": true,
                       "collectOsAndBrowser": false,
                       "collectMethod": false
                   },
                   "serviceMain": {
                       "class": "Service_HTTP",
                       "virtualAddresses": [
                           "<virtual>"
                       ],
                       "pool": "web_pool",
                       "profileAnalytics": {
                           "use": "statsProfile"
                       }
                   },
                   "web_pool": {
                       "class": "Pool",
                       "monitors": [
                           "http"
                       ],
                       "members": [
                           {
                               "servicePort": 80,
                               "serverAddresses": [
                                   "<node1>",
                                   "<node2>"
                               ],
                               "shareNodes": true
                           }
                       ]
                   }
               }
           }
       }
   }

2. Now that the AS3 declaration is validated, modify the Virtual Address to 10.1.10.110 and the serverAddresses to 10.1.20.110 and 10.1.20.111.

3. Using **Visual Studio code REST client extension**, find the **BIG-IQ Token** call and replace IP address in the URL with ``10.1.1.8`` instead of ``10.1.1.4`` 
   (**BOS-vBIGIP01.termmarc.com** instead of BIG-IQ). 
   Replace in the **body** username and password with::

    {
        "username": "admin",
        "password": "purple123",
        "loginProviderName": "tmos"
    }

   Then, authenticate on the BIG-IP and save the token.

4. Use the **BIG-IQ AS3 Declaration** call in order to create the service on the BIG-IP.
   Replace IP address in the URL with ``10.1.1.8`` instead of ``10.1.1.4``.
   The method and URL used will be ``POST https://10.1.1.8/mgmt/shared/appsvcs/declare``.
   Copy/Paste the AS3 declaration to the body under the call using the REST client VS code extension.
   
   This will give you an ID which you can query using the **BIG-IQ Check AS3 Deployment Task**.

5. Login on **BOS-vBIGIP01.termmarc.com** and verify the application is correctly deployed in partition Task1.

Deploy AS3 Application Service through BIG-IQ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Now the application service has been deployed directly on the BIG-IP, let's re-deploy the same AS3 declaration but through BIG-IQ.

2. Add the target (BIG-IP device) to the AS3 declaration used earlier between ``remark`` and ``Task1``::

    "remark": "Task 1 - HTTP Application Service",
    "target": {
        "address": "<BIG-IP ip address>"
    },
    "Task1": {

3. Using **Visual Studio code REST client extension**, find the **BIG-IQ Token** call to authenticate you on the BIG-IQ and save the token.
   Replace IP address in the URL with ``10.1.1.4`` instead of ``10.1.1.8``.

4. Use the **BIG-IQ AS3 Declaration** call in order to create the service on the BIG-IP through BIG-IQ.
   Replace IP address in the URL with ``10.1.1.4`` instead of ``10.1.1.8``.
   The method and URL used will be ``POST https://10.1.1.4/mgmt/shared/appsvcs/declare``.
   Copy/Paste the AS3 declaration to the body under the call using the REST client VS code extension.

.. warning:: If the request is failing, check if the Boston BIG-IP Cluster in sync.

5. Login on **BIG-IQ** as **david**, go to Applications tab and check the application is displayed and analytics are showing.

.. warning:: Starting 7.0, BIG-IQ displays AS3 application services created using the AS3 Declare API as Unknown Applications.
             You can move those application services using the GUI, the `Move/Merge API`_, `bigiq_move_app_dashboard`_ F5 Ansible Galaxy role 
             or create it directly into Application in BIG-IQ using the `Deploy API`_ to define the BIG-IQ Application name.

.. _Move/Merge API: https://clouddocs.f5.com/products/big-iq/mgmt-api/v0.0/ApiReferences/bigiq_public_api_ref/r_as3_move_merge.html
.. _Deploy API: https://clouddocs.f5.com/products/big-iq/mgmt-api/v0.0/ApiReferences/bigiq_public_api_ref/r_as3_deploy.html
.. _bigiq_move_app_dashboard: https://galaxy.ansible.com/f5devcentral/bigiq_move_app_dashboard