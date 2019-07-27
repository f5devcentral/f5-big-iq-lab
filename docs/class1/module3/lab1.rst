Lab 3.1: Create Application via API with Ansible (6.0.x only)
-------------------------------------------------------------
.. warning:: Starting BIG-IQ 6.1, AS3 should be the preferred method to deploy application services programmatically through BIG-IQ. Go `here`_ if you are on 6.1 or later.

.. _here: ../module5/module5.html

In this lab, we are going to deploy a basic HTTP application using Ansible.

The following parameters are filled in the playbook ``create_http_bigiq_app.yaml``.

- BIG-IP: Select ``SEA-vBIGIP01.termmarc.com``
- Collect HTTP Statistics ``yes``
- Application Name: ``site22.example.com``
- Destination Address: ``10.1.10.122``
- Destination Network Mask: ``255.255.255.255``
- Service Port: ``80``
- Servers (Pool Member): ``10.1.20.122``

Connect via ``SSH`` to the system *Ubuntu Lamp Server*.

Execute the playbook::

    # cd /home/f5/f5-ansible-bigiq-service-catalog-demo
    # ansible-playbook -i notahost, create_http_bigiq_app.yaml -vvvv

.. warning :: If the ansible playbook run successfully but the app doesn't show up, please, review david's role.

.. note :: If you prefer not to wait until the app is created, you can switch the variable ``wait`` to ``no`` in the playbook.

Connect as **olivia** (select Auth Provider local) and check on BIG-IQ the application has been correctly created.
