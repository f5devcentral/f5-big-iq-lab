Lab 11.3: Add Key to Regkey Pool
-----------------------------------

In this lab, we will add a new key to the previously created regkey pool on BIG-IQ. 

**Prerequisites**
- BIG-IQ Regkey Pool name
- BIG-IP registration key(s)

1. Navigate to the **Templates** page and review ``(Mod11-Lab3) Add_BIGIQ_Regkey``.

.. image:: /pictures/lab-3-1.png
  :scale: 60%
  :align: center

Ensure that the admin_iq (BIG-IQ) credentials appear in the **CREDENTIALS** field.

.. image:: /pictures/lab-3-2.png
  :scale: 60%
  :align: center

You can go on the `GitHub repository`_ and check review the playbooks and Jinja2 templates.

.. _GitHub repository: https://github.com/f5devcentral/f5-big-iq-lab/tree/develop/lab/f5-ansible-bigiq-as3-demo/tower

2. Back on the **Templates** page, next to the *(Mod11-Lab3) Add_BIGIQ_Regkey* template, click on the *Start a job using this template*.

.. image:: /pictures/lab-3-3.png
  :scale: 60%
  :align: center

3. **SURVEY**: Enter in the name of your regkey pool and the new key.

+-----------------------------+--------------------------+
| REGISTRATION KEY POOL NAME  | regkey_pool_BT_200M      |
+-----------------------------+--------------------------+
| REGISTRATION KEY            | XXXX-XXXX-XXXX-XXXX-XXXX |
+-----------------------------+--------------------------+

.. image:: /pictures/lab-3-4.png
  :scale: 60%
  :align: center

4. **PREVIEW**: Review the summary of the template deployment, then click on **LAUNCH**.

.. image:: /pictures/lab-3-5.png
  :scale: 60%
  :align: center

5. Follow the JOB deployment of the Ansible playbook.

.. image:: /pictures/lab-3-6.png
  :scale: 60%
  :align: center

6. When the job is completed, check the PLAY RECAP and make sure there nothing failed.

.. image:: /pictures/lab-3-7.png
  :scale: 60%
  :align: center

7. Login on **BIG-IQ** as **admin**, go to Devices tab > LICENSE MANAGEMENT > Licenses.  Click on the regkey pool and check the newly added key.

.. image:: /pictures/lab-3-8.png
  :scale: 60%
  :align: center

You can repeat this task if you want to add multiple regkeys. 

This completes the regkey add lab. 