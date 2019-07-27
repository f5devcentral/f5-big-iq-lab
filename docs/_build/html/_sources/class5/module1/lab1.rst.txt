Lab 1.1: Import a device to an existing Cluster
-----------------------------------------------

.. warning:: **BOS-vBIGIP02.termmarc.com (10.1.10.10)** is currently managed by BIG-IQ CM, however it is in the same Device Service Cluster (DSC) with BOS-vBIGIP01. We will be adding this device to BIG-IQ. 

Log in to the BIG-IQ system with your user name (david) and password (david).

On the top menu bar, select Devices from the BIG-IQ menu.

On the left-hand menu bar, click BIG-IP Devices.

Select **BOS-vBIGIP02.termmarc.com** and click on **Remove All Service**, then when all services are removed, click on **Remove Device**.

Click the Add Device button in the main pane.

a. In the IP Address field, type the IP address of the device: **10.1.10.10**

b. In the User Name and Password fields, type the user name (david) and password (david) for the device.

c. Cluster Display Name: **Use Existing**.

d. Select a Cluster: **BostonCluster**

e. Leave everything else default.

.. list-table::
   :header-rows: 1
   :widths: 30 30

   * - Name
     - Value
   * - ``IP Address``
     - 10.1.10.10
   * - ``username``
     - admin
   * - ``password``
     - admin
   * - ``Cluster Display Name``
     - Use Existing
   * - ``Select A Cluster``
     - Boston Cluster
 

|image1|

Click the Add button to add this device to BIG-IQ.

BIG-IQ now exchanges certs with the BIG-IP and pops up a window for the administrator to select which modules to manage from BIG-IQ. For this device, select LTM, ASM, AFM and DNS Services. Keep the Statistics monitoring boxes all checked, and then click the Continue button.

|image2|

The discovery process will start, and you should see a screen similar to the following screenshot. At this point, BIG-IQ is using REST calls to the BIG-IP to pull the selected parts of the BIG-IP configuration into BIG-IQ.

|image3|

Allow the import jobs to complete. At this point, the configuration of
the BIG-IPs that have been imported are not yet editable in BIG-IQ. To
make the configurations editable in BIG-IQ, we need to complete the
import tasks.

.. |image1| image:: media/image1.png
   :width: 6.49583in
   :height: 4.29167in
.. |image2| image:: media/image2.png
   :width: 6.49583in
   :height: 4.41667in
.. |image3| image:: media/image3.png
   :width: 6.50000in
   :height: 1.54167in
