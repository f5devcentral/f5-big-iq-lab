Lab 2.7: Perform lab 1, 2 and 4 using Ansible
---------------------------------------------

.. note:: Estimated time to complete: **20 minutes**

This lab will be using the following F5 Ansible Galaxy roles:
    - `atc_deploy`_  **ansible Role**: Allows AS3 declaration to be sent to `automation tool chain`_ service.
    - `bigiq_move_app_dashboard`_ **ansible Role**: Move Application Service(s) in BIG-IQ Application Dashboard.

.. include:: /accesslab.rst

Tasks
^^^^^

You can look at the details of the AS3 declarations on the `GitHub repository`_.

.. _GitHub repository: https://github.com/f5devcentral/f5-big-iq-lab/blob/develop/lab/f5-ansible-bigiq-as3-demo/as3

Connect via ``SSH`` or ``Web Shell`` to the system *Ubuntu Lamp Server*. *(if you use the Web Shell, login as f5student first: su - f5student)*.

Execute the playbooks for each tasks.

.. warning:: Starting 7.0, BIG-IQ displays AS3 application services created using the AS3 Declare API as Unknown Applications.
             You can move those application services using the GUI, the `Move/Merge API`_, `bigiq_move_app_dashboard`_ F5 Ansible Galaxy role 
             or create it directly into Application in BIG-IQ using the `Deploy API`_ to define the BIG-IQ Application name.

.. _Move/Merge API: https://clouddocs.f5.com/products/big-iq/mgmt-api/latest/ApiReferences/bigiq_public_api_ref/r_as3_move_merge.html
.. _Deploy API: https://clouddocs.f5.com/products/big-iq/mgmt-api/latest/ApiReferences/bigiq_public_api_ref/r_as3_deploy.html

.. _atc_deploy: https://galaxy.ansible.com/f5devcentral/atc_deploy
.. _bigiq_move_app_dashboard: https://galaxy.ansible.com/f5devcentral/bigiq_move_app_dashboard
.. _automation tool chain: https://www.f5.com/products/automation-and-orchestration

- Task 1: HTTP Application Service::

    cd /home/f5/f5-ansible-bigiq-as3-demo
    ./cmd_bigiq_as3_apps_creation.sh as3_bigiq_task01_create_http_app.json

  Login as **david** and check on BIG-IQ the application has been correctly created.

|

- Task 2: HTTPS Offload::

    cd /home/f5/f5-ansible-bigiq-as3-demo
    ./cmd_bigiq_as3_apps_creation.sh as3_bigiq_task02_create_https_app.json

  Login as **david** and check on BIG-IQ the application has been correctly created.

|

- Task 3a: HTTPS Application with Web Application Firewall::

    cd /home/f5/f5-ansible-bigiq-as3-demo
    ./cmd_bigiq_as3_apps_creation.sh as3_bigiq_task03a_create_waf_app.json

  Login as **david** and check on BIG-IQ the application has been correctly created.

|

- Task 4: Generic Services::

    cd /home/f5/f5-ansible-bigiq-as3-demo
    ./cmd_bigiq_as3_apps_creation.sh as3_bigiq_task04_create_generic_app.json

  Login as **david** and check on BIG-IQ the application has been correctly created.

|

- Task 5a: Add a HTTPS Application to existing HTTP AS3 Declaration (using POST)::

    cd /home/f5/f5-ansible-bigiq-as3-demo
    ./cmd_bigiq_as3_apps_creation.sh as3_bigiq_task05a_modify_post_http_app.json

  Login as **david** and check on BIG-IQ the application has been correctly created.

|

- Move Task1 application services into a single Application on BIG-IQ::

    cd /home/f5/f5-ansible-bigiq-as3-demo
    ./ansible_helper ansible-playbook /ansible/bigiq_as3_move_apps.yml -i /ansible/hosts

  Login as **david** and check on BIG-IQ the application has been correctly created.

  .. warning:: If you want Paula to access the new Application called LAB_task1, David will need to assign the role ``LAB_task1 Manager``

  |lab-3-5|

|

- Task 9: Delete Task1 with their AS3 application services::

    cd /home/f5/f5-ansible-bigiq-as3-demo
    ./cmd_bigiq_as3_apps_creation.sh as3_bigiq_task09_delete_task1_app.json

  Login as **david** on BIG-IQ.

  Here, we empty the tenant/partition Task1. This should remove those partitions from BOS-vBIGIP01.termmarc.com. The relevant Apps 
  should also disappear from BIG-IQ. 

.. |lab-3-1| image:: ../pictures/module2/lab-3-1.png
   :scale: 60%
.. |lab-3-2| image:: ../pictures/module2/lab-3-2.png
   :scale: 60%
.. |lab-3-3| image:: ../pictures/module2/lab-3-3.png
   :scale: 60%
.. |lab-3-4| image:: ../pictures/module2/lab-3-4.png
   :scale: 60%
.. |lab-3-5| image:: ../pictures/module2/lab-3-5.png
   :scale: 60%