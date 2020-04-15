Lab 2.2: Troubleshooting Pool Member
------------------------------------
1. Login as **paula** in BIG-IQ.

2. Select the application service ``security_site16_boston`` located under ``airport_security`` application.

.. image:: ../pictures/module2/img_module2_lab2_1.png
  :align: center
  :scale: 40%

|

3. Click on the **SERVERS**, then select the **CONFIGURATION** tab. 1 node should be displayed.

.. image:: ../pictures/module2/img_module2_lab2_2.png
  :align: center
  :scale: 40%

|

4. Click on **Create** and add a wrong node ``1.3.5.6``, click **Create**

.. image:: ../pictures/module2/img_module2_lab2_3.png
  :align: center
  :scale: 40%

|

You should see a *Deploying application changes...* yellow banner indicating the deployment is on going.

5. An alarm is raised showing the wrong pool member.

.. note:: The monitors for the default templates are set to 1 minute in order to reducing the probability that with a network issue

.. image:: ../pictures/module2/img_module2_lab2_4.png
  :align: center
  :scale: 40%

|

6. Delete the pool member previously created during step 3. to clear the alarm.
