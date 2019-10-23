Lab 6.5: Security workflow (AS3)
--------------------------------

Task 3 - HTTPS Application with Web Application Firewall
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


This declaration will create an HTTPS application on BIG-IQ using an HTTPS template, a WAF policy and a security Log Profile.

.. note:: The ASM policy & Log Profiles need to be deployed first in BIG-IP if it exists only on BIG-IQ.
             Attached the policy to the ``inactive`` virtual server under the Web Application Security Configuration menu, then deploy it.


Let's first deploy the default Advance WAF policy and Security Logging Profile available in **BIG-IQ** to **BIG-IP A**.

#. Deploy the default BIG-IQ WAF Policy

Logon on **BIG-IQ** as **david**, go to configuration tab, SECURITY, Web Application Security, Policies. ``templates-default`` is the default WAF policy available on BIG-IQ.

|lab-2-5a|

Under Virtual Servers, click on the ``inactive`` virtual server attached to **bigip-a.f5.local**.

|lab-2-5b|

Select the ``/Common/templates-default``, then click on Save & Close.

|lab-2-6|

Notice the policy is now atached to the ``inactive`` virtual servers . Select the ``inactive`` virtual servers attached to **bigip-a.f5.local** and **bigip-b.f5.local**, click on Deploy.

|lab-2-7|

The deployment window opens. Type a name, select ``Deploy immediately`` for the Method, under the Target Device(s) section, click on ``Find Relevant Devices``
and select the **bigip-a.f5.local** and **bigip-b.f5.local**. Then, click on Deploy.

|lab-2-8|

Confirm the deployment, click on Deploy.

|lab-2-9|

Wait for the deployment to complete.

|lab-2-10|

#. Deploy the default BIG-IQ Security Logging Profile

Still under configuration tab, SECURITY, Shared Security, Logging Profiles. ``templates-default`` is the default Security Logging Profile available on BIG-IQ.

|lab-2-11|

Under Pinning Policies, click on the **bigip-a.f5.local** device.

|lab-2-12|

In the Shared Security drop down menu, select Logging Profiles.

|lab-2-13|

Select the ``templates-default``, then click on Add Selected.

|lab-2-14|

Confirm the logging profile has been added under Logging Profiles and click on Save & Close.

|lab-2-15|

Repeat previous steps for **bigip-b.f5.local** device.

Back on Logging Profiles, select the ``templates-default`` and click on Deploy.

|lab-2-16|

The deployment window opens. Type a name, select ``Deploy immediately`` for the Method, under the Target Device(s) section, click on ``Find Relevant Devices``
and select the **bigip-a.f5.local** and **bigip-b.f5.local**. Then, click on Deploy.

|lab-2-17|

Confirm the deployment, click on Deploy.

|lab-2-9|

Wait for the deployment to complete.

|lab-2-18|

#. Now both Advance WAF policy and Security Logging Profile are available on BIG-IP A, let's provision the WAF application service using AS3 & BIG-IQ.

This declaration will create an HTTPS application on BIG-IQ using an HTTPS template, a WAF policy and a security Log Profile.

Update the WAF policy section below with the policy available on BIG-IP::

   "policyWAF": {
         "bigip": "/Common/templates-default"
      }

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 36

   {
      "class": "AS3",
      "action": "deploy",
      "persist": true,
      "declaration": {
         "class": "ADC",
         "schemaVersion": "3.7.0",
         "id": "isc-lab",
         "label": "Task3",
         "remark": "Task 3 - HTTPS Application with WAF",
         "target": {
               "hostname": "bigip-a.f5.local"
         },
         "Task3": {
               "class": "Tenant",
               "MyWebApp3waf": {
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
                           "10.1.20.128"
                     ],
                     "pool": "web_pool",
                     "profileAnalytics": {
                           "use": "statsProfile"
                     },
                     "serverTLS": "webtls",
                     "policyWAF": {
                           "bigip": "/Common/<WAF Policy>"
                     },
                     "securityLogProfiles": [
                           {
                              "bigip": "/Common/templates-default"
                           }
                     ]
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
                                 "10.1.10.100",
                                 "10.1.10.101"
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
         }
      }
   }

#. Using Postman, use the **BIG-IQ Token (david)** collections to authenticate you on the BIG-IQ and save the token.
   If your token expires, obtain a new token by resending the ``BIG-IQ Token (david)``.

   .. WARNING:: The token timeout is set to 5 min. If you get the 401 authorization error, request a new token.

#. Use the **BIG-IQ AS3 Declaration** call in order to create the service on the BIG-IP through BIG-IQ.
   Copy/Paste the above AS3 declaration into the declaration body into Postman *(DON'T FORGET TO UPDATE THE WAF Policy)*:

   POST https://10.1.1.4/mgmt/shared/appsvcs/declare?async=true
   
   This will give you an ID which you can query using the **BIG-IQ Check AS3 Deployment Task**

#. Use the **BIG-IQ Check AS3 Deployment Task** Postman calls to ensure that the AS3 deployment is successfull without errors: 

   GET https://10.1.1.4/mgmt/shared/appsvcs/task/<id>

#. Logon to **BIG-IQ** as **david**, go to Application tab and check the application is displayed and analytics are showing.


.. |lab-2-0| image:: images/lab-2-0.png
   :scale: 60%
.. |lab-2-1| image:: images/lab-2-1.png
   :scale: 60%
.. |lab-2-2| image:: images/lab-2-2.png
   :scale: 60%
.. |lab-2-3| image:: images/lab-2-3.png
   :scale: 60%
.. |lab-2-4| image:: images/lab-2-4.png
   :scale: 60%
.. |lab-2-5a| image:: images/lab-2-5a.png
   :scale: 60%
.. |lab-2-5b| image:: images/lab-2-5b.png
   :scale: 60%
.. |lab-2-6| image:: images/lab-2-6.png
   :scale: 60%
.. |lab-2-7| image:: images/lab-2-7.png
   :scale: 60%
.. |lab-2-8| image:: images/lab-2-8.png
   :scale: 60%
.. |lab-2-9| image:: images/lab-2-9.png
   :scale: 70%
.. |lab-2-10| image:: images/lab-2-10.png
   :scale: 60%
.. |lab-2-11| image:: images/lab-2-11.png
   :scale: 60%
.. |lab-2-12| image:: images/lab-2-12.png
   :scale: 60%
.. |lab-2-13| image:: images/lab-2-13.png
   :scale: 60%
.. |lab-2-14| image:: images/lab-2-14.png
   :scale: 60%
.. |lab-2-15| image:: images/lab-2-15.png
   :scale: 60%
.. |lab-2-16| image:: images/lab-2-16.png
   :scale: 60%
.. |lab-2-17| image:: images/lab-2-17.png
   :scale: 60%
.. |lab-2-18| image:: images/lab-2-18.png
   :scale: 60%
.. |lab-2-19| image:: images/lab-2-19.png
   :scale: 60%
