Lab 6.3: Legacy Application and RBAC: Paula workflow
----------------------------------------------------

.. note:: Estimated time to complete: **15 minutes**

.. include:: /accesslab.rst

Tasks
^^^^^

1. Login to BIG-IQ as **david**. 

2. Here we are going to add RBAC to the newly created legacy application. Go to **System > User Management > Users** and select **Paula**.

Add ``Lab_Module6 Manager`` Role as seen below.

.. image:: ../pictures/module6/lab-3-2.png
  :scale: 40%
  :align: center

Next add the ``legacy-app-service`` Role and then Click **Save & Close**.

.. image:: ../pictures/module6/lab-3-3.png
  :scale: 40%
  :align: center


3. Now logout from the **david** session and login to BIG-IQ as **paula**.

.. image:: ../pictures/module6/lab-3-4.png
  :scale: 40%
  :align: center

4. Select ``LAB_module6`` Application, then ``legacy-app-service`` Application Service.

.. image:: ../pictures/module6/lab-3-5.png
  :scale: 40%
  :align: center

5. You are now on the Paula's Application Services dashboard. Click on Servers on the right side of the screen.

.. image:: ../pictures/module6/lab-3-6.png
  :scale: 40%
  :align: center

6. Select Configuration and try to disable one of the Pool Member.

.. image:: ../pictures/module6/lab-3-7.png
  :scale: 40%
  :align: center

7. Confirm the pool member is disabled.

.. image:: ../pictures/module6/lab-3-8.png
  :scale: 40%
  :align: center
