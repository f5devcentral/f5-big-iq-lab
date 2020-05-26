Lab 1: Manage AS3 Templates on BIG-IQ
-------------------------------------

.. include:: ./accesslab.rst

Exercise 1.1 – Import AS3 templates
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**View AS3 templates section**

1. From within the LAMP server RDP/noVNC session, logon to BIG-IQ as **david** *(david\\david)*
      by opening a browser and go to: ``https://10.1.1.4`` or directly via
      the TMUI.

2. Go to Applications > Application Templates and review the top section
      which is titled **AS3 Templates**.

A new BIG-IQ v7.0 deployment will NOT include AS3 templates out of the
box. If you want to start using AS3 templates which are provided by F5,
then those AS3 templates can be found through the following
link: https://github.com/f5devcentral/f5-big-iq

.. note:: The F5 default AS3 BIG-IQ templates are already imported in the lab environment blueprint.

**Import AS3 BIG-IQ templates**

1. Select **Import Templates** at the right top corner. You will be
   taken to the BIG-IQ AS3 Template Library on Github.

..

   |image4|

2. Make yourself familiar with the Github page and understand which AS3
   templates are available.

3. The AS3 templates are already imported in BIG-IQ and you don’t need
   to perform step 4.

4. Use the provided instructions on the Github page to import the
   templates into BIG-IQ.

.. note:: The F5 default AS3 BIG-IQ templates are already imported in the lab environment blueprint.

5. Walk through the provided templates and select them to understand the
   structure. If familiar with AS3 you will notice the structure.
   Otherwise, visit `AS3 Example
   declarations <https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/userguide/examples.html.>`__.

..

Exercise 1.2 – Deploy application via BIG-IQ using a default AS3 template
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this exercise we will create an application service using an AS3
template. The service will include a pool with two pool members (server
addresses) listening on port 80, a virtual server listening on port 443
and various profiles to offload SSL to the pool members.

First we attempt to create an application service as application owner
Paula.

1. From within the LAMP server RDP/noVNC session, logon on **BIG-IQ** as **paula** *(paula\\paula)*
    by opening a browser and go to: ``https://10.1.1.4`` or directly via
    the TMUI as shown above.

2. In the **Applications** page click on **Create** to create an
   Application Service

|image5|

+--------------------------------------------------------------------------------------------------+
| Application properties:                                                                          |
+==================================================================================================+
| -  Grouping = New Application                                                                    |
|                                                                                                  |
| -  Application Name = **LAB 1.2**                                                                |
|                                                                                                  |
| -  Description = My first AS3 template deployment with BIG-IQ                                    |
+--------------------------------------------------------------------------------------------------+
| Select an Application Service Template:                                                          |
+--------------------------------------------------------------------------------------------------+
| -  Template Type = Select AS3-F5-HTTPS-offload-lb-existing-cert-template-big-iq-default-v1 [AS3] |
+--------------------------------------------------------------------------------------------------+

**Warning**

   You will notice that the template is not available. If we want Paula
   to deploy services using this template, we first need to have those templates
   assigned to her via an administrator.

3. Logout as **paula** and login to BIG-IQ as **david**. (if asked: Leave site? Select: Leave)

4. Select **Applications > Application Templates** and notice the
   ‘Published’ templates. The template **Paula** wants to use is
   listed as a ‘Published’ template.

|image6|

5. Go to **System > Role Management > Roles** and
   select **Application Roles** under the **CUSTOM ROLES** section.
   Here you will see the collection of the Custom Application Roles.

|image7|

6. **Paula** is assigned to the
   exiting Application Creator VMware custom role. Select it and scroll
   down to AS3 Templates. As you can see, **Paula** does not have
   permission to deploy an AS3 application
   using AS3-F5-HTTPS-offload-lb-existing-cert-template.

|image8|

7. Select AS3-F5-HTTPS-offload-lb-existing-cert-template-big-iq-default-v1 AS3
   Template and click the arrow to get it in
   the **‘Selected’** section. Then, select **Save & Close**.

8. Logout as David and log back in as **Paula** and
   click **Create** to create an application.

9. Select Create Application to Create an Application Service:

|image9|

+----------------------------------------------------------------------------------------------------+
| Application properties:                                                                            |
+----------------------------------------------------------------------------------------------------+
| * Grouping = New Application                                                                       |
| * Application Name = ``LAB 1.2``                                                                   |
| * Description = ``My first AS3 template deployment with BIG-IQ``                                   |
+----------------------------------------------------------------------------------------------------+
| Select an Application Service Template:                                                            |
+----------------------------------------------------------------------------------------------------+
| * Template Type = Select ``AS3-F5-HTTPS-offload-lb-existing-cert-template-big-iq-default [AS3]``   |
+----------------------------------------------------------------------------------------------------+
| General Properties:                                                                                |
+----------------------------------------------------------------------------------------------------+
| * Application Service Name = ``https_app_service``                                                 |
| * Target = ``SEA-vBIGIP01.termmarc.com``                                                           |
| * Tenant = ``tenant1``                                                                             |
+----------------------------------------------------------------------------------------------------+
| Pool                                                                                               |
+----------------------------------------------------------------------------------------------------+
| * Members: ``10.1.20.120``, port ``80``                                                            |
| * Members: ``10.1.20.121``, port ``80``                                                            |
+----------------------------------------------------------------------------------------------------+
| TLS_Server. Keep default.                                                                          |
+----------------------------------------------------------------------------------------------------+
| Certificate. Keep default.                                                                         |
+----------------------------------------------------------------------------------------------------+
| Service_HTTPS                                                                                      |
+----------------------------------------------------------------------------------------------------+
| * Virtual addresses: ``10.1.10.120``                                                               |
+----------------------------------------------------------------------------------------------------+
| Analytics_Profile. Keep default.                                                                   |
+----------------------------------------------------------------------------------------------------+

|image10|

10. Go to View Sample API Request in the right upper corner and select
    it. You will have a full AS3 declaration schema, scroll through it
    and hit close when done.

|image11|

11. Click **Create**.

12. Check that the Application LAB 1.2 has been created.

|image12|

.. note:: If not visible, refresh the page.

13. Select **LAB 1.2** Application. You will
    notice **LAB 1.2** acts as a group of Application Services where
    underneath multiple services can be grouped. The next window will
    show you that a new Application Service has been created
    named: tenant1_https_app_service.

|image13|

14. Now, let’s look on the BIG-IP and verify the Application is
    correctly deployed in partition tenant1.

Logon to SEA-vBIGIP01.termmarc.com BIG-IP as **admin** from the lab
environment. Select the partition tenant1 and look at the objects
created on the BIG-IP.

|image14|

15. You can test the application service by open a browser in the Ubuntu
       Jumphost and type the Virtual Server IP address 10.1.10.120. You
       should see the Hackazon website.

16. Back on the BIG-IQ as **paula**,
       select tenant1_https_app_service Application Service and look
       for HTTP traffic analytics.

|image15|

.. note:: An HTTP traffic generator is running on the Jumphost.

**Exercise 1.3 - Modify template**

Through the GUI *and when allowed*, the application owner can make small
modifications.

1. In tenant1_https_app_service, select Servers >> Configuration and add
   a Pool Member.

-  Click the + next to the second Server Address and add: 10.1.20.122.

-  Click **Save & Close**.

|image16|

2. Once the configuration change has completed in BIG-IQ,
   check SEA-vBIGIP01.termmarc.com (partition tenant1) Local Traffic >
   Pools and find **Pool**. It will have tenant1/https_app_service as
   the partition/path (or use search). Select Pool and go to members.

|image17|

3. Now back to the BIG-IQ and tenant1_https_app_service application and
   select **Application Service > Configuration.** Scroll down in the
   AS3 declaration and find that the schema has added the third pool
   member.

|image18|

|image19|

Using **BIG-IQ** to modify application services deployed via AS3 is only 
possible if the application was initially deployed via BIG-IQ.  Services 
deployed via AS3 directly to the **BIG-IP**, whether via Postman, Ansible, or 
other toolchains, must continue to use that toolchain to modify the service. 

The BIG-IQ GUI only allows you to modify what has been permitted (made
‘editable’) when the template was created. With a configuration deployed
through the API directly to the BIG-IP and not via BIG-IQ, you would
need to redeploy to add additional services.


.. |image4| image:: images/lab1/image5.png
   :width: 6.5in
   :height: 2.22778in
.. |image5| image:: images/lab1/image6.png
   :width: 6.5in
   :height: 3.23889in
.. |image6| image:: images/lab1/image7.png
   :width: 6.5in
   :height: 3.26806in
.. |image7| image:: images/lab1/image8.png
   :width: 6.5in
   :height: 2.95764in
.. |image8| image:: images/lab1/image9.png
   :width: 5.84306in
   :height: 9in
.. |image9| image:: images/lab1/image10.png
   :width: 6.5in
   :height: 6.73056in
.. |image10| image:: images/lab1/image11.png
   :width: 6.5in
   :height: 3.12014in
.. |image11| image:: images/lab1/image12.png
   :width: 6.5in
   :height: 2.49306in
.. |image12| image:: images/lab1/image13.png
   :width: 6.5in
   :height: 2.41389in
.. |image13| image:: images/lab1/image14.png
   :width: 6.5in
   :height: 3.8875in
.. |image14| image:: images/lab1/image15.png
   :width: 6.5in
   :height: 3.18403in
.. |image15| image:: images/lab1/image16.png
   :width: 6.5in
   :height: 3.20347in
.. |image16| image:: images/lab1/image17.png
   :width: 6.5in
   :height: 3.88611in
.. |image17| image:: images/lab1/image18.png
   :width: 5.48in
   :height: 6.22647in
.. |image18| image:: images/lab1/image19.png
   :width: 5.48in
   :height: 6.22647in
.. |image19| image:: images/lab1/image20.png
   :width: 5.48in
   :height: 6.22647in