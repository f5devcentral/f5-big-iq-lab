Lab 6.3: Legacy Application and RBAC: Paula workflow
----------------------------------------------------

Because the vip134 ``legacy-app-service`` was deployed on a cluster (see `known issue`_), 
we need to first re-create the Legacy Application Service ``legacy-app-service`` on BIG-IQ.

This is not needed on Standalone BIG-IP, but only on cluster. Because of this limitation, it is
recommended to create and attach the analytics profile to the VIP before the creation
of the legacy application service on the BIG-IQ dashboard. This would be the recommended
 production workflow for customers.

.. _known issue: https://techdocs.f5.com/kb/en-us/products/big-iq-centralized-mgmt/releasenotes/related/relnote-supplement-big-iq-central-mgmt-7-1-0.html#A899789

1. Login to BIG-IQ as **david**. Delete the Application **legacy-app-service**.

.. image:: ../pictures/module6/lab-3-1.png
  :scale: 40%
  :align: center

..note:: Don't worry, the application service is only deleted on the BIG-IQ application dashboard, not on BIG-IP!

Follow `Lab 1`_  to re-create the legacy application service. This time select **Part of an existing Application** and
choose **LAB_module6**. Then select **Using existing device configuration**. For name use **legacy-app-service** then 
select **BOS-vBIGIP01.termmarc.com**. Choose **HTTP+TCP** for the Application Service, and then move **vip134** to the **Selected** column.

Scroll down and notice there is no warning for the **Profile HTTP Analytics** as we did not changge the virtual server configuration
from the previous steps. Click **Create**.

.. _Lab 1: ./lab1.html

2. Here we are going to add RBAC to the newly created legacy application. Go to **System > User Management > Users** and select **Paula**.

Add ``Lab_Module6 Manager`` Role as seen below.

.. image:: ../pictures/module6/lab-3-2.png
  :scale: 40%
  :align: center

Next add the ``legacy-app-service`` Role and then Click **Save & Close**.

.. image:: ../pictures/module6/lab-3-3.png
  :scale: 40%
  :align: center


3. Now logout from the david session and Login to BIG-IQ as **paula**.

.. image:: ../pictures/module6/lab-3-4.png
  :scale: 40%
  :align: center

4. Select ``LAB_module6`` Application, then ``legacy-app-service`` Application Service.

.. image:: ../pictures/module6/lab-3-5.png
  :scale: 40%
  :align: center

5. You are now on the Paula's Application Services dashboard. Click on Server on the right side of the screen.

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

8. Now, look at the changes in the analytics and then re-enable the pool member.