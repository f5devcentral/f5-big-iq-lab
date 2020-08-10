Lab 2.5: FQDN and Service Discovery
-----------------------------------

.. include:: /accesslab.rst

Tasks
^^^^^

Connect via ``SSH`` to the system *Ubuntu Lamp Server*.

Execute the playbooks for each tasks

- Task 10: HTTP Application Service using an FQDN pool to identify pool members::

    # cd /home/f5/f5-ansible-bigiq-as3-demo
    # ./cmd_bigiq_as3_apps_creation.sh as3_bigiq_task10_create_http_app_fqdn_nodes.json paul

Connect as **paul** and check on BIG-IQ the application has been correctly created.

|lab-5-1|

Connect on the BIG-IP and look at the **fqdn_pool**:

|lab-5-2|


.. |lab-5-1| image:: ../pictures/module2/lab-5-1.png
   :scale: 60%

.. |lab-5-2| image:: ../pictures/module2/lab-5-2.png
   :scale: 60%

.. warning:: BIG-IQ won't display the number of servers in the dashboard for FQDN nodes.