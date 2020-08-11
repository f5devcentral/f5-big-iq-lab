Lab 2.2: Troubleshooting Pool Member
------------------------------------

.. note:: Estimated time to complete: **5 minutes**

.. include:: /accesslab.rst

Tasks
^^^^^
1. Login as **paula** in BIG-IQ.

2. Select the application service ``security_site16_boston`` located under ``airport_security`` application.

.. image:: ../pictures/module2/img_module2_lab2_1.png
  :align: center
  :scale: 40%

|

3. Click on the **SERVERS**, then select the **CONFIGURATION** tab. 2 nodes should be displayed.

.. image:: ../pictures/module2/img_module2_lab2_2.png
  :align: center
  :scale: 40%

|

4. Add a Pool Member.

* Click the + next to Server Addresses and add a wrong node ``1.3.5.6`` for ``123``.

* Click **Save & Close**.

.. image:: ../pictures/module2/img_module2_lab2_3.png
  :align: center
  :scale: 40%

|

You should see a spinner indicating the deployment is on going.

5. An alarm is raised showing the wrong pool member. Notice couple events are showing the alarm on the analytics charts.

.. image:: ../pictures/module2/img_module2_lab2_4.png
  :align: center
  :scale: 40%

|

If you look at the details of the alarms, you will be able to see the pool members server address down.

.. image:: ../pictures/module2/img_module2_lab2_5.png
  :align: center
  :scale: 40%

|

6. Delete the wrong pool member created during step 4. to clear the alarm.
