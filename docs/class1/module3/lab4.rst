Lab 3.4: Security workflow with BIG-IQ and AS3: WAF
---------------------------------------------------

Workflow:

1. **Larry** create the ASM policy in transparent mode on the BIG-IQ and deploy on the BIG-IP(s).
2. **David** create the AS3 template and reference ASM policy created by **Larry** in the template.
3. **David** assign the AS3 template to Paula.
4. **Paula** create her application service using the template given by **david**.
5. After **Paula** does the necessary testing of her application, she reach to Larry.
6. **Larry** review the ASM learning and deploy the ASM policy changes on the BIG-IP(s) and set the policy to blocking mode.
7. They all go for happy hour.

Prerequisites
^^^^^^^^^^^^^

1. First make sure your device has ASM module discovered and imported 
for **SEA-vBIGIP01.termmarc.com** under Devices > BIG-IP DEVICES.

2. Check if the **Web Application Security** service is Active 
under System > BIOG-IQ DATA COLLECTION > BIG-IQ Data Collection Devices.

ASM Policy creation (Larry)
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Let's first deploy the default Advance WAF policy and Security Logging Profile available in **BIG-IQ** to **SEA-vBIGIP01.termmarc.com**.

#. Logon to BIG-IQ as **larry** by opening a browser and go to: ``https://10.1.1.4``

#. Go to Configuration > Security > Web Application Security > Policies and clone the policy called ``templates-default``
and name it as ``templates-default-cloned``.

.. image:: ../pictures/module3/lab-5-1a.png
  :scale: 60%
  :align: center

.. image:: ../pictures/module3/lab-5-1b.png
  :scale: 60%
  :align: center

#. Select ``templates-default-cloned`` and change **Enforcement Mode** to ``transparent`` under POLICY BUILDING > Settings, then click on Save & Close.
  
.. image:: ../pictures/module3/lab-5-1c.png
  :scale: 60%
  :align: center

#. Under Virtual Servers, click on the ``inactive`` virtual server attached to **SEA-vBIGIP01.termmarc.com**.

.. image:: ../pictures/module3/lab-5-2.png
  :scale: 60%
  :align: center

#. Select the ``/Common/templates-default-cloned``, then click on Save & Close.

.. image:: ../pictures/module3/lab-5-3.png
  :align: center

#. Notice the policy is now atached to the ``inactive`` virtual servers.

Select the ``inactive`` virtual servers attached to **SEA-vBIGIP01.termmarc.com**, click on Deploy.

.. image:: ../pictures/module3/lab-5-4.png
  :scale: 60%
  :align: center

#. The deployment window opens. Type a name, select ``Deploy immediately`` for the Method.

.. image:: ../pictures/module3/lab-5-5.png
  :scale: 60%
  :align: center

Under the Target Device(s) section, click on ``Find Relevant Devices``
and select the **SEA-vBIGIP01.termmarc.com**. Then, click on Deploy.

.. image:: ../pictures/module3/lab-5-6.png
  :scale: 60%
  :align: center

#. Confirm the deployment information, click on Deploy.

.. image:: ../pictures/module3/lab-5-7.png
  :scale: 60%
  :align: center

#. Wait for the deployment to complete.

.. image:: ../pictures/module3/lab-5-8.png
  :scale: 60%
  :align: center

Once the deployment is completed, you confirm the changes by clicking on *view**.

.. image:: ../pictures/module3/lab-5-9.png
  :scale: 60%
  :align: center

#. Deploy the default BIG-IQ Security Logging Profile so the ASM events are being sent correctly to BIG-IQ DCD.

.. note:: This step is only for your information as it's already perform in this lab.

Under configuration tab, SECURITY, Shared Security, Logging Profiles. ``templates-default`` 
is the default Security Logging Profile available on BIG-IQ.

.. image:: ../pictures/module3/lab-5-10.png
  :scale: 60%
  :align: center

#. Under Pinning Policies, click on the **SEA-vBIGIP01.termmarc.com** device.

Confirm the logging profile has been added under Logging Profiles.

.. image:: ../pictures/module3/lab-5-11.png
  :scale: 60%
  :align: center

WAF AS3 template (David)
^^^^^^^^^^^^^^^^^^^^^^^^

Until now we used a default AS3 template out-of-the-box (available on https://github.com/f5devcentral/f5-big-iq) 
for deploying an application service. It is a good practice to clone the default AS3 templates and use them more 
tailored to your custom needs.

#. Logon as **david** and go to the Application > Application Templates and 
   select ``AS3-F5-HTTPS-WAF-existing-lb-template-big-iq-default-<version>`` and press **Clone**.

#. Give the Cloned template a name: ``AS3-LAB-HTTPS-WAF-custom-template`` and click Clone.

.. image:: ../pictures/module3/lab-5-12.png
  :scale: 60%
  :align: center

#. Open the template ``AS3-LAB-HTTPS-WAF-custom-template`` and select the ``Analytics_Profile`` AS3 class.
   Change to Override the Properties ``Collect Client-Side Statistics``, 
   as well as ``Collect URL`` and ``Collect User Agent``.

.. image:: ../pictures/module3/lab-5-13a.png
  :scale: 60%
  :align: center

.. note:: ``Response Code``, ``User Method`` and ``Operating System and Brower`` are already 
enabled by default in the AS3 schema.

#. Now, select the ``Service_HTTPS`` AS3 class.
   Change to the properties ``bigip`` under policyWAF to ``/Common/templates-default-cloned``.
   Make sure the properties is set to Editable.

.. note:: If you want to hide the ASM policy in the template, you can set the properties to Override
(only starting BIG-IQ 7.1, see BIG-IQ 7.0 Release note #811013).

.. image:: ../pictures/module3/lab-5-13b.png
  :scale: 60%
  :align: center

#. Click **Save & Close**.

#. Select ``AS3-LAB-HTTPS-WAF-custom-template`` and click **Publish**.

#. Before **paula** can use this AS3 template, **david** needs to update her role.
   Use the previous steps in `Lab 3.2`_ to add AS3 Template ``AS3-LAB-HTTPS-WAF-custom-template`` to ``Application Creator VMware`` custom role
   assigned to **paula**.

.. _Lab 3.2: ../lab2.html

WAF AS3 Application Service (Paula)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now both Advance WAF policy and Security Logging Profile are available on BIG-IP and AS3 WAF template 
available on BIG-IQ, let's create the WAF application service using AS3 & BIG-IQ.

#. Login as **paula** and select previously created ``LAB_module3`` Application and click **Create**.
  
#. Select Create Application to Create an Application Service:

+---------------------------------------------------------------------------------------------------+
| Application properties:                                                                           |
+---------------------------------------------------------------------------------------------------+
| * Grouping = Part of an Existing Application                                                      |
| * Application Name = ``LAB_module3``                                                              |
| * Description = ``My second AS3 template deployment through a GUI``                               |
+---------------------------------------------------------------------------------------------------+
| Select an Application Service Template:                                                           |
+---------------------------------------------------------------------------------------------------+
| * Template Type = Select ``AS3-LAB-HTTPS-WAF-custom-template [AS3]``                              |
+---------------------------------------------------------------------------------------------------+
| General Properties:                                                                               |
+---------------------------------------------------------------------------------------------------+
| * Application Service Name = ``https_waf_app_service``                                            |
| * Target = ``SEA-vBIGIP01.termmarc.com``                                                          |
| * Tenant = ``tenant2``                                                                            |
+---------------------------------------------------------------------------------------------------+
| Analytics_Profile. Keep default                                                                   |
+---------------------------------------------------------------------------------------------------+
| Pool                                                                                              |
+---------------------------------------------------------------------------------------------------+
| * Members: ``10.1.20.123``                                                                        |
+---------------------------------------------------------------------------------------------------+
| Service_HTTPS                                                                                     |
+---------------------------------------------------------------------------------------------------+
| * Virtual addresses: ``10.1.10.122``                                                              |
| * policyWAF: ``/Common/templates-default-cloned``                                                                 |
+---------------------------------------------------------------------------------------------------+
| Certificate. Keep default                                                                         |
+---------------------------------------------------------------------------------------------------+
| TLS_Server. Keep default                                                                          |
+---------------------------------------------------------------------------------------------------+

.. image:: ../pictures/module3/lab-5-14a.png
  :scale: 60%
  :align: center

.. image:: ../pictures/module3/lab-5-14b.png
  :scale: 60%
  :align: center

#. Click **Create**.

#. Check the Application Service ``https_waf_app_service`` has been created under Application ``LAB_module3``.

.. image:: ../pictures/module3/lab-5-15.png
  :scale: 60%
  :align: center

#. Now, let's look on the BIG-IP  and verify the Application is correctly deployed in partition ``tenant2``.
    
#. Logon to ``SEA-vBIGIP01.termmarc.com`` BIG-IP from lab environment. Select the partition ``tenant2`` and look at the objects created on the BIG-IP.

 .. image:: ../pictures/module3/lab-5-16.png
   :scale: 60%
  :align: center
  
#. Notice that new ``https_waf_app_service`` comes with a redirect. Select the HTTPS VS, Select Security and 
hit Policies. Application Security Policy is Enabled and the Log Profile has a templates-default selected.
 
.. image:: ../pictures/module3/lab-5-17.png
  :scale: 60%
  :align: center

#. Back to the BIG-IQ and logged in as **paula**, select ``tenant2_https_waf_app_service``. What is the enforced Protection Mode?

.. image:: ../pictures/module3/lab-5-18.png
  :scale: 60%
  :align: center

#. From the lab environment, launch a xRDP/noVNC session to have access to the Ubuntu Desktop. 
To do this, in your lab environment, click on the *Access* button
of the *Ubuntu Lamp Server* system and select *noVNC* or *xRDP*.

.. note:: Modern laptops with higher resolutions you might want to use 1440x900 and once XRDP is launched Zoom to 200%.

.. image:: ../../pictures/udf_ubuntu.png
    :align: left
    :scale: 60%

|

Open Chrome and navigate to the following URL: ``https\:\/\/10.1.10.120`` and 
login with username: paula, password: paula

.. image:: ../pictures/module3/lab-5-19.png
  :scale: 60%
  :align: center

Paula does the necessary testing of her application, she reach to Larry.

.. note:: There are traffic generator sending good and bad traffic from the Lamp server in the lab.

Paula can update Application Service Health Alert Rules by clicking on the Health Icon on the top left of the Application Dashboard.

.. image:: ../pictures/module3/lab-5-20a.png
  :align: center

.. image:: ../pictures/module3/lab-5-20b.png
  :scale: 60%
  :align: center


ASM Policy Learning review (Larry & Paula)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#. Logon as **larry** and go to Configuration > Security > Web Application Security > Policies.

#. Select ``templates-default-cloned`` and navigate under POLICY BUILDING > Suggestions and review the learning.

.. image:: ../pictures/module3/lab-5-21.png
  :scale: 60%
  :align: center

#. Accept necessary suggestions.

.. image:: ../pictures/module3/lab-5-22.png
  :scale: 60%
  :align: center

.. node:: In case the app is deployed on a BIG-IP HA pair, the learning is not sync unless the failover group is set to automatic or the centrally builder feature is used.

#. Navigate under POLICY BUILDING > Settings, change **Enforcement Mode** to ``blocking`` then click on Save & Close.

.. image:: ../pictures/module3/lab-5-23.png
  :scale: 60%
  :align: center

#. Select the ``templates-default-cloned``, click on Deploy to deploy the changes (same as previously done).

.. image:: ../pictures/module3/lab-5-24.png
  :scale: 60%
  :align: center

#. Let's generate some bad traffic, connect on the Ubuntu Lamp Server server and launch the following script::

  /home/f5/scripts/generate_http_bad_traffic.sh

#. Check ASM type of attacks by navigating under Monitoring > EVENTS > Web Application Security > Event Logs > Events

.. image:: ../pictures/module3/lab-5-25.png
  :scale: 60%
  :align: center

#. Login as **paula** and select previously created ``LAB_module3`` Application, then click on ``https_waf_app_service``.

In Application Dashboard, navigate to the Security Statistics and notice the Malicious Transactions.

.. image:: ../pictures/module3/lab-5-26.png
  :scale: 60%
  :align: center