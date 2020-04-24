Lab 5.1: Import a device into a silo
-------------------------------------

1. Login to BIG-IQ as **david** by opening a browser and go to: ``https://10.1.1.4``

2. Navigate to Devices > BIG-IP Devices. You can hide some columns you won't need 
   for this lab such as Stats Collection, Data Collection, Stats Last Collection.

.. image:: ../pictures/img_module5_lab1-1.png
  :scale: 40%
  :align: center

3. Click on *Complete import tasks* under **SJC-vBIGIP01.termmarc.com** Services.

.. image:: ../pictures/img_module5_lab1-2.png
  :scale: 40%
  :align: center

4. Click on Import to start the device configuration import in BIG-IQ.

.. image:: ../pictures/img_module5_lab1-3.png
  :scale: 40%
  :align: center

5. The conflict resolution window opens. All the objects are given the options, Set all BIG-IQ,
   Set all BIG-IP or Create Version except 1 object ``silo-lab-http-profile`` which only has the 2 first
   options.

The HTTP profile ``silo-lab-http-profile`` already exist in BIG-IQ and belongs to one of the BIG-IP discovered & imported
in BIG-IQ such as the Boston BIG-IP Cluster or the Seattle BIG-IP.

.. image:: ../pictures/img_module5_lab1-4.png
  :scale: 40%
  :align: center

.. note:: More details on Version Specific Objects in `Module 4`_.

.. _Module 4: ../module4/module4.html

6. Select the ``silo-lab-http-profile`` profile HTTP and see the difference between BIG-IQ and the device profile.

- BIG-IQ

+--------------------------+----------+
| Accept XFF               | Enabled  |
+--------------------------+----------+
| Insert X-Forwarded-For   | Enabled  |
+--------------------------+----------+

- SJC-vBIGIP01.termmarc.com

+--------------------------+----------+
| Accept XFF               | Disabled |
+--------------------------+----------+
| Insert X-Forwarded-For   | Disabled |
+--------------------------+----------+

.. image:: ../pictures/img_module5_lab1-5.png
  :scale: 40%
  :align: center

Because we want to preserve both profile HTTP, click on **Resolve Conflicts Later**.

7. Select **Create a New Silo** and name it ``silolab``

.. image:: ../pictures/img_module5_lab1-6.png
  :scale: 40%
  :align: center

The device is added into the ``silolab``.

.. image:: ../pictures/img_module5_lab1-7.png
  :scale: 40%
  :align: center

.. note:: If you know all the devices from 1 data center have the same conflicts, 
          you can put all of those devices in the same silo and fix the conflict once.

8. Once the device is added to the silo, import the device configuration.

.. image:: ../pictures/img_module5_lab1-8.png
  :scale: 40%
  :align: center

9. On the devices grid, you can see now **SJC-vBIGIP01.termmarc.com** belongs to ``silolab``.

.. image:: ../pictures/img_module5_lab1-9.png
  :scale: 40%
  :align: center

10. If you navigate to the Configuration tab > Local Traffic > Profile and filter on ``silo-lab-http-profile``
    you will see the HTTP profile which is part of the default silo (main stream) and the New
    profile from the SJC BIG-IP device into the ``silolab``.

.. image:: ../pictures/img_module5_lab1-10.png
  :scale: 40%
  :align: center
