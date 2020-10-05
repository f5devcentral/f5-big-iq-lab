Module 10: Distribute User-provided GeoIP DB update package to BIG-IPs (new 7.1)
================================================================================

.. note:: Estimated time to complete: **10 minutes**

The BIG-IP system uses geolocation software to identify the geographic location of a client
or web application user. The default IP geolocation database provides IPv4 addresses at 
the continent, country, state, ISP, and organization levels, and IPv6 addresses at the 
continent and country levels. 

F5 regularly releases database updates in the GeoLocationUpdates container on the F5 Downloads site.

.. include:: /accesslab.rst

Tasks
^^^^^

1. Follow the steps to download the geolocation database and MD5 described in the following article `K22650515`_ (choose `BIG-IP v15.x`_).

.. _K22650515: https://support.f5.com/csp/article/K22650515

.. _BIG-IP v15.x: https://downloads.f5.com/esd/product.jsp?sw=BIG-IP&pro=big-ip_v15.x

2. You should have now 2 ip-geolocation files (1 zip and 1 MD5).

3. Login to BIG-IQ as **david** *(open a Remote Desktop session to the Ubuntu Jump-host or access directly to the BIG-IQ CM)*.

4. Go to Devices > Geo-IP Database Management > Database Files.

.. image:: pictures/lab-1-1.png
  :scale: 40%
  :align: center

5. Delete any existing Geo Database file(s) if any.

.. image:: pictures/lab-1-2.png
  :scale: 40%
  :align: center

6. Upload the files downloaded earlier.

.. image:: pictures/lab-1-3.png
  :scale: 40%
  :align: center

**Save & Close**.

7. Now, let's check the location of the following IP address ``192.1.0.11`` before updating the GeoIP DB on the BIG-IP.

Go to Devices > Script Management > Script. Create a new script.

- Name: ``geoip_lookup``
- Script: ``geoip_lookup 192.1.0.11``

.. image:: pictures/lab-1-4.png
  :scale: 40%
  :align: center

**Save & Close**.

.. note:: `K15042`_: Looking up IP geolocation data using the geoip_lookup command

.. _K15042: https://support.f5.com/csp/article/K15042

8. Select the script created and click on **Run**. Set a name, select ``SJC-vBIGIP01.termmarc.com`` BIG-IP,
   then click on **Run**.

.. image:: pictures/lab-1-5.png
  :scale: 40%
  :align: center

A window will open, *Click the link to see the result: Script Log*.

9. Once the script execution is completed, click on **View Output**.

.. image:: pictures/lab-1-6.png
  :scale: 40%
  :align: center

10. The IP address ``192.1.0.11`` shows a location in Massachusetts in the United States.

.. image:: pictures/lab-1-7.png
  :scale: 40%
  :align: center

11. Back to the Geo-IP Database Management, under Devices, select ``SJC-vBIGIP01.termmarc.com`` BIG-IP and click on **Update**.

.. image:: pictures/lab-1-8.png
  :scale: 40%
  :align: center

Verify the correct BIG-IP is selected, then click on **Save & Close**.

.. image:: pictures/lab-1-9.png
  :scale: 40%
  :align: center

A window will open, *Click the link to see the result: Updates History*.

12. Wait until the transfer is done.

.. image:: pictures/lab-1-10.png
  :scale: 40%
  :align: center

13. Back in the Script Management window, select again the script ``geoip_lookup``, 
    run it against ``SJC-vBIGIP01.termmarc.com`` and verify the output.

.. image:: pictures/lab-1-11.png
  :scale: 40%
  :align: center

Is the location of the IP address still on the East Coast of the Unites States?