Lab 1.7: Upgrade Managed Devices to New Versions of TMOS with BIG-IQ
--------------------------------------------------------------------
A key feature of BIG-IQ is the ability to manage software images for multiple remote devices from one location.
You can deploy software without having to log in to each individual BIG-IP device.

There are three steps to managing software images for devices:

- Download the software image from F5 Networks.
- Upload the software image to BIG-IQ.
- Install the software image on a device in the BIG-IP Device inventory in one of the following two ways:
    - Managed Device Upgrade - use this process for installing a software image on managed BIG-IP devices running version 11.5.0 or later.
    - Legacy Device Upgrade - use this process for installing a software image on BIG-IP devices running versions 10.2.4 to 11.4.1.

Official documentation about BIG-IP Software Upgrades can be found on the `F5 Knowledge Center`_.

.. _F5 Knowledge Center: https://techdocs.f5.com/en-us/bigiq-7-1-0/managing-big-ip-devices-from-big-iq/big-ip-software-upgrades.html

.. raw:: html

    <iframe width="560" height="315" src="https://www.youtube.com/embed/fR2O864JQwY" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

|

.. include:: /accesslab.rst

Tasks
^^^^^

1. Login to BIG-IQ as **david**.

2. Navigate to the DEVICE tab. Look at the device list, specifically at the BIG-IP versions. In this lab, we are going to upgrade the SEA-vBIGIP01.termmarc.com BIG-IP to the latest 14.1 version.

.. image:: ./media/lab-7-0.png
  :scale: 40%
  :align: center

3. Navigate under Software Management, Software Images. Select the BIG-IP 14.1 image and click on **Manage Device Install**.

.. image:: ./media/lab-7-1.png
  :scale: 40%
  :align: center

4. Type a name for the task (e.g. ``seattle-upgrade``) and select the desired option for the BIG-IP upgrade.

Click on **Add/Remove Devices**

.. image:: ./media/lab-7-2.png
  :scale: 40%
  :align: center

5. The device list shows up. Select SEA-vBIGIP01.termmarc.com.

.. image:: ./media/lab-7-3.png
  :scale: 40%
  :align: center

6. Set the Target Volume name to ``HD1.2``, click on **Save**, then **Run**.

.. image:: ./media/lab-7-4.png
  :scale: 40%
  :align: center

7. The first step is to initiate the transfer of the iso file on the BIG-IP.

.. image:: ./media/lab-7-5.png
  :scale: 40%
  :align: center

8. Once the image transfer is completed, the next step is to take a ucs backup of the device. Click on **Back Up Devices**.

.. image:: ./media/lab-7-6.png
  :scale: 40%
  :align: center

9. Once the backup is completed, launch the **Run Pre-assessment**.

.. image:: ./media/lab-7-7.png
  :scale: 40%
  :align: center

Select all the options. 

.. image:: ./media/lab-7-8.png
  :scale: 40%
  :align: center

Then, press **Continue**.

.. image:: ./media/lab-7-9.png
  :scale: 40%
  :align: center

10. The software upgrade is starting. This step is typically done during a maintenance window. Time to take a coffee (or do another lab)!

.. image:: ./media/lab-7-10.png
  :scale: 40%
  :align: center

11. Once the software installation is completed, proceed with the reboot. Click on **Continue**.

.. image:: ./media/lab-7-11.png
  :scale: 40%
  :align: center

12. After the reboot complete, click on **Run All Post-Assessment**.

.. image:: ./media/lab-7-12.png
  :scale: 40%
  :align: center

And **Compare Assessment** to see what LTM differs from prior upgrade.

.. image:: ./media/lab-7-13.png
  :scale: 40%
  :align: center

Example of assessments comparison.

.. image:: ./media/lab-7-14.png
  :scale: 40%
  :align: center

13. Finally, when the Post-Assessment and software upgrade completed successfully, click on **Mark Finished**.

.. image:: ./media/lab-7-15.png
  :scale: 40%
  :align: center

14. Go back to the Device tab and re-import and re-discover SEA-vBIGIP01.termmarc.com, important step to perform after the BIG-IP upgrade.

.. image:: ./media/lab-7-17.png
  :scale: 40%
  :align: center
