Lab 2.8: AS3 Application Creation using AWX/Ansible Tower and BIG-IQ
--------------------------------------------------------------------

.. note:: Estimated time to complete: **20 minutes**

.. include:: /accesslab.rst

Application Service Creation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Click on the *AWX (Ansible Tower)* button on the system *Ubuntu Lamp Server* in lab environment.
Use ``admin/purple123`` to authenticate.

.. image:: ../pictures/module2/lab-8-1.png
  :scale: 60%
  :align: center

1. Navigate to the **Projects** page and click on the refesh button to get the latest version of the templates.

.. image:: ../pictures/module2/lab-8-2.png
  :scale: 60%
  :align: center

2. Navigate to the **Templates** page and review ``(Class1-Mod2-Lab8) New_AS3_App``

.. image:: ../pictures/module2/lab-8-3.png
  :scale: 60%
  :align: center

Make sure the **PLAYBOOK** ``lab/f5-ansible-bigiq-as3-demo/tower/app_create.yml`` is selected.

.. image:: ../pictures/module2/lab-8-4.png
  :scale: 60%
  :align: center

You can go on the `GitHub repository`_ and check review the playbooks and Jinja2 templates.

.. _GitHub repository: https://github.com/f5devcentral/f5-big-iq-lab/tree/develop/lab/f5-ansible-bigiq-as3-demo/tower

3. Back on the **Templates** page, next to the *(Class1-Mod2-Lab8) New_AS3_App* template, click on the *Start a job using this template*.

.. image:: ../pictures/module2/lab-8-5.png
  :scale: 60%
  :align: center

4. **CREDENTIAL**: Select ``BIG-IQ Creds`` as **Credential Type**. Then select ``paula-iq``.

.. image:: ../pictures/module2/lab-8-6.png
  :scale: 60%
  :align: center

5. **SURVEY**: Enter below information regarding your application service definition.

+-------------------+-------------------------------+
| TENANT NAME       | AnsibleTower                  |
+-------------------+-------------------------------+
| APP SERVICE NAME  | MyApp139                      |
+-------------------+-------------------------------+
| APP TYPE          | http_app or waf_app           |
+-------------------+-------------------------------+
| SERVICE IP        | 10.1.10.139                   |
+-------------------+-------------------------------+
| NODES             | 10.1.20.120 and 10.1.20.121   |
+-------------------+-------------------------------+


.. image:: ../pictures/module2/lab-8-7.png
  :scale: 60%
  :align: center

6. **PREVIEW**: Review the summary of the template deployment, then click on **LAUNCH**.

.. image:: ../pictures/module2/lab-8-8.png
  :scale: 60%
  :align: center

7. Follow the JOB deployment of the Ansible playbook.

.. image:: ../pictures/module2/lab-8-9.png
  :scale: 60%
  :align: center

.. note:: The *FAILED - RETRYING* messages are expected as the playbook runs into a LOOP to check the AS3 task completion 
          and will show failed until loop isn't completed.

8. When the job is completed, check the PLAY RECAP and make sure there are no failed.

.. image:: ../pictures/module2/lab-8-10.png
  :scale: 60%
  :align: center

9. Login on **BIG-IQ** as **paula**, go to Applications tab and check the application is displayed and analytics are showing.

.. image:: ../pictures/module2/lab-8-11.png
  :scale: 60%
  :align: center

Select ``AnsibleTower`` Application, select ``AnsibleTower_MyApp139`` Application Service and look HTTP traffic analytics.

.. image:: ../pictures/module2/lab-8-12.png
  :scale: 60%
  :align: center

Application Service Deletion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The application owner has informed Paul that the application is no longer needed and needs to be deleted. Paul will use an AS3 declaration and BIG-IQ to remove the previously added application from the BIG-IPs. 

1. Return to *AWX (Ansible Tower)* and if needed log back in as **paul** *(paul\\paul)*  
   Navigate to the **Templates** page and click on *(Agility 2020) Delete_AS3_App*

2. Click on the *Launch* button to start a job using this
   template*. 

3. **CREDENTIAL**: Select *BIG-IQ Creds* as **Credential Type**. Then
   select *paul-iq*. Click on *NEXT*

4. **SURVEY**: Enter below information regarding your application
   service definition. Click on *NEXT.*

+-------------+-------------------------------+
| TENANT NAME | AnsibleTower                  |
+-------------+-------------------------------+

5. **PREVIEW**: Review the summary of the template deployment. 
   Click on *LAUNCH*

6. Follow the JOB deployment of the Ansible playbook.

   The *FAILED - RETRYING* messages are expected as the playbook runs into a LOOP to check the AS3 task 
   completion and will show failed until loop is completed.

7.  When the job is completed, check the **PLAY RECAP** and make sure that *failed=* status is **0**.

8. Logon on **BIG-IQ** as **paul** *(paul\\paul)*, go to main Application page 
    
9. Select *Unknown Applications* Application tile

10. Notice that the application is now deleted.