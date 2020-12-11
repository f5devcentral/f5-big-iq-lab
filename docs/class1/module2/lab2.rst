Lab 2.2: Modify Tenant/Application using AS3
--------------------------------------------

.. note:: Estimated time to complete: **25 minutes**

Using the declarative AS3 API, let's modify the HTTP application created during the previous **Lab 1 - Task 1** through BIG-IQ using an updated AS3 declaration.

In this lab, we will show 2 use cases.

- Task 5a will show an example of updating a tenant/application by re-posting the entire declaration using POST. In this case, user A and user B need to know the full content of the Tenant.
- Task 5b will show an example of updating a tenant/application by posting only what's new to an existing declaration using PATCH. In this case, user A and user B don't need to know the full content of the Tenant but 1 single tenant can be shared.

.. include:: /accesslab.rst

Task 5a - Add a HTTPS Application to existing HTTP AS3 Declaration (using POST)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This declaration will add a HTTPS application to a existing HTTP application. In this task, we will re-submit the entire declaration.

1. Start with the previous AS3 Declaration from **lab 1 - Task 1**

.. code-block:: yaml
   :linenos:

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
           "target": {
               "address": "10.1.1.8"
           },
           "Task1": {
               "class": "Tenant",
               "MyWebApp1http": {
                   "class": "Application",
                   "template": "http",
                   "statsProfile": {
                       "class": "Analytics_Profile",
                        "collectedStatsInternalLogging": true,
                        "collectPageLoadTime": true,
                        "collectClientSideStatistics": true,
                        "collectResponseCode": true
                   },
                   "serviceMain": {
                       "class": "Service_HTTP",
                       "virtualAddresses": [
                           "10.1.10.110"
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
                                   "10.1.20.110",
                                   "10.1.20.111"
                               ],
                               "shareNodes": true
                           }
                       ]
                   }
               }
           }
       }
   }

2. Add the below application service to the existing AS3 declaration in the JSON validator. The validator is your IDE (Integrated development environment).
   
   Use the IDE available within the lab environment, click on the *Access* button
   of the *Ubuntu Lamp Server* system and select *Visual Studio Code*.

   .. note:: It is recommended to `validate your AS3 declaration`_ against the schema using Microsoft Visual Studio Code.

   .. _validate your AS3 declaration: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/userguide/validate.html
   
.. note:: Add a **","** at the end of the MyWebApp1 statement.
          If you want to "minimize" MyWebApp1 statement (like in the screenshot below), click on the tiny down arrow on the left of this line


|lab-2-1|

.. code-block:: yaml
   :linenos:

   "MyWebApp6https": {
           "class": "Application",
           "template": "https",
           "statsProfile": {
               "class": "Analytics_Profile",
               "collectClientSideStatistics": true,
               "collectOsAndBrowser": false,
               "collectMethod": false
           },
           "serviceMain": {
               "class": "Service_HTTPS",
               "virtualAddresses": [
                   "10.1.10.129"
               ],
               "pool": "web_pool",
               "profileAnalytics": {
                   "use": "statsProfile"
               },
               "serverTLS": "webtls"
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
                           "10.1.20.128",
                           "10.1.20.129"
                       ],
                       "shareNodes": true
                   }
               ]
           },
           "webtls": {
               "class": "TLS_Server",
               "certificates": [
                   {
                       "certificate": "webcert"
                   }
               ]
           },
           "webcert": {
               "class": "Certificate",
               "certificate": {
                   "bigip": "/Common/default.crt"
               },
               "privateKey": {
                   "bigip": "/Common/default.key"
               }
           }
       }

3. Open Visual Studio Code, then use the VS code REST client extension and authenticate to BIG-IQ (follow |location_link_vscode_restclient2|).

4. Use the **BIG-IQ AS3 Declaration** call in order to create the service on the BIG-IP through BIG-IQ.    
   The method and URL used will be ``POST https://10.1.1.4/mgmt/shared/appsvcs/declare?async=true``.
   Copy/Paste the AS3 declaration from the validator to the body under the call using the REST client VS code extension.
   
   This will give you an ID which you can query using the **BIG-IQ Check AS3 Deployment Task**.

5. Use the **BIG-IQ Check AS3 Deployment Task** call to ensure that the AS3 deployment is successful without errors: 

   ``GET https://10.1.1.4/mgmt/shared/appsvcs/task/<id>``

6. Login on BIG-IQ as **david**, go to Applications tab and check the application is displayed and analytics are showing.

.. warning:: Starting 7.0, BIG-IQ displays AS3 application services created using the AS3 Declare API as Unknown Applications.
             You can move those application services using the GUI, the `Move/Merge API`_, `bigiq_move_app_dashboard`_ F5 Ansible Galaxy role 
             or create it directly into Application in BIG-IQ using the `Deploy API`_ to define the BIG-IQ Application name.

Task 5b - Add a HTTPS Application to existing HTTP AS3 Declaration (using PATCH)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. warning:: This isn't the recommended way of adding an application to an existing Tenant. The method described in Task 5a is preferred.
             The PATCH operation will be fully supported starting with BIG-IQ 7.0/AS3.12 and above (not supported in BIG-IQ 6.1/AS3.7)

This declaration will create add a HTTP application to a existing Tenant. In this task, we will submit only the new application using the PATCH.

.. note:: The target from the previous declaration is preserved when building the new declaration with the patch.

1. Add the below application service to the existing AS3 declaration in the validator. The validator is your IDE (Integrated development environment).
   
   Use the IDE available within the lab environment, click on the *Access* button
   of the *Ubuntu Lamp Server* system and select *Visual Studio Code*.

   You can also use an online tool such as `www.jsonschemavalidator.net`_.

   .. _validate your AS3 declaration: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/userguide/validate.html

   .. _www.jsonschemavalidator.net: https://www.jsonschemavalidator.net/

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 4, 8, 11

    {
        "$schema": "https://raw.githubusercontent.com/F5Networks/f5-appsvcs-extension/master/schema/latest/as3-schema.json",
        "class": "AS3",
        "action": "patch",
        "patchBody": [
            {
               "target": {
                    "address": "10.1.1.8"
                },
                "path": "/Task1/MyWebApp7http",
                "op": "add",
                "value": {
                    "class": "Application",
                    "template": "http",
                    "serviceMain": {
                        "class": "Service_HTTP",
                        "virtualAddresses": [
                            "10.1.10.131"
                        ],
                        "pool": "web_pool"
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
                                  "10.1.20.130",
                                  "10.1.20.131"
                                ],
                                "shareNodes": true
                            }
                        ]
                    }
                }
            }
        ]
    }

3. Open Visual Studio Code, then use the VS code REST client extension and authenticate to BIG-IQ (follow |location_link_vscode_restclient2|).

4. Use the **BIG-IQ AS3 Declaration** call in order to create the service on the BIG-IP through BIG-IQ.    
   The method and URL used will be ``POST https://10.1.1.4/mgmt/shared/appsvcs/declare?async=true``.
   Copy/Paste the AS3 declaration from the validator to the body under the call using the REST client VS code extension.
   
   This will give you an ID which you can query using the **BIG-IQ Check AS3 Deployment Task**.

5. Use the **BIG-IQ Check AS3 Deployment Task** call to ensure that the AS3 deployment is successful without errors: 

   ``GET https://10.1.1.4/mgmt/shared/appsvcs/task/<id>``

6. Login on BIG-IQ as **david**, go to Applications tab and check the application is displayed and analytics are showing.

.. warning:: Starting 7.0, BIG-IQ displays AS3 application services created using the AS3 Declare API as Unknown Applications.
             You can move those application services using the GUI, the `Move/Merge API`_, `bigiq_move_app_dashboard`_ F5 Ansible Galaxy role 
             or create it directly into Application in BIG-IQ using the `Deploy API`_ to define the BIG-IQ Application name.

.. _Move/Merge API: https://clouddocs.f5.com/products/big-iq/mgmt-api/latest/ApiReferences/bigiq_public_api_ref/r_as3_move_merge.html
.. _Deploy API: https://clouddocs.f5.com/products/big-iq/mgmt-api/latest/ApiReferences/bigiq_public_api_ref/r_as3_deploy.html
.. _bigiq_move_app_dashboard: https://galaxy.ansible.com/f5devcentral/bigiq_move_app_dashboard

.. |lab-2-1| image:: ../pictures/module2/lab-2-1.png
   :scale: 60%
.. |lab-1-5| image:: ../pictures/module2/lab-1-5.png
   :scale: 40%

.. |location_link_vscode_restclient2| raw:: html

   <a href="/training/community/big-iq-cloud-edition/html/vscode_restclient.html" target="_blank">instructions</a>