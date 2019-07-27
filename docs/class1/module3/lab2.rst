Lab 3.2: Delete Application via API with Ansible (6.0.x only)
-------------------------------------------------------------
.. warning:: Starting BIG-IQ 6.1, AS3 should be the preferred method to deploy application services programmatically through BIG-IQ. Go `here`_ if you are on 6.1 or later.

.. _here: ../module5/module5.html

In this lab, we are going to delete an application using Ansible.

Connect via ``SSH`` to the system *Ubuntu Lamp Server*.

**olivia** user is used to execute the playbook:

Execute the playbook::

    # cd /home/f5/f5-ansible-bigiq-service-catalog-demo
    # ansible-playbook -i notahost, delete_http_bigiq_app.yaml -vvvv

Connect as **olivia** (select Auth Provider local) and check on BIG-IQ the application has been correctly deleted.
