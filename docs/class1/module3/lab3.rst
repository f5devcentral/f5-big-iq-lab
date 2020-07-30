Lab 3.3: AS3 Application Service modification through BIG-IQ UI
---------------------------------------------------------------

.. include:: /accesslab.rst

Tasks
~~~~~

Through the GUI and when allowed, the application owner is able to make small modifications.

1. In ``tenant1_https_app_service``, click on the **SERVERS**, then select the **CONFIGURATION** tab 
   and add a Pool Member.

* Click the + next to Server Addresses and add: ``10.1.20.122``.

* Click **Save & Close**.

.. image:: ../pictures/module3/lab-3-1.png
  :scale: 40%
  :align: center

2. Check ``SEA-vBIGIP01.termmarc.com`` (partition ``tenant1``) Local Traffic > Pools and find **Pool**.
   It will have tenant1/https_app_service as the partition/path (or use search). Select Pool and go to members.

.. image:: ../pictures/module3/lab-3-2.png
  :scale: 60%
  :align: center   

3. Now back to the BIG-IQ and ``tenant1_https_app_service`` application service.
   Click on **View Sample API Request** in the right upper corner and select it. 
   You will have a full AS3 declaration schema, scroll down in the AS3 declaration and 
   find that the schema has added the second pool member.

.. image:: ../pictures/module3/lab-3-3.png
  :align: center
  :scale: 60%

The GUI only allows you to modify what has been permitted (made 'editable') when the template was created.

Through the API, you can modify the AS3 application service once deployed by doing a PATCH or re-sending the full
declaration through a POST (see `Module 2`_ for more details on BIG-IQ and AS3 using the API). 

.. _Module 2: ../module2/module2.html