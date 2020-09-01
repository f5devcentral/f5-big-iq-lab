Lab 1.2: Configuring SMTP for sending alerts to Splunk
------------------------------------------------------
.. note:: Estimated time to complete: **5 minutes**

This feature provides the ability for the customer to specify a message to be displayed on the BIG-IQ login page.

.. include:: /accesslab.rst

Tasks
^^^^^
**Prerequisites Splunk**

- This demo is using a instance of Splunk running in a `container`_.
- An `HTTP Event Collector`_ listening on port 8088 to receive JSON events has been configured.

.. _container: https://hub.docker.com/r/splunk/splunk/
.. _HTTP Event Collector: https://dev.splunk.com/enterprise/docs/dataapps/httpeventcollector/

Send SNMP events to your Splunk deployment
https://docs.splunk.com/Documentation/Splunk/latest/Data/SendSNMPeventstoSplunk#How_to_index_SNMP_traps

Monitor files and directories with the CLI
https://docs.splunk.com/Documentation/Splunk/latest/Data/MonitorfilesanddirectoriesusingtheCLI



1. Connect via ``SSH`` to the system *Ubuntu Lamp Server*.

2. Execute the following commands::

    ./tools/startSNMPtrapListener.sh

1. Open BIG-IQ, go to **System > This Device > SNMP Configuration > SNMP Traps**


.. image:: ../pictures/module1/img_module1_lab2_1.png
  :align: center
  :scale: 60%

