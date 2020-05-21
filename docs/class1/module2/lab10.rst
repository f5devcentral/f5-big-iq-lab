Lab 2.10: Moving existing AS3 Application Services from BIG-IP to BIG-IQ
------------------------------------------------------------------------

In this lab, we are going to see the process to move AS3 Application Services already 
deployed directly on BIG-IP using the API on BIG-IQ.

The process consist simply to add the target property under the ADC class in the 
AS3 declaration and re-send the full declaration to the BIG-IQ declare or deploy-to-application APIs.

From the lab environment, launch a remote desktop session to have access to the Ubuntu Desktop.
To do this, in your lab environment, click on the *Access* button
of the *Ubuntu Lamp Server* system and select *noVNC* or *xRDP*.

.. note:: Modern laptops with higher resolutions you might want to use 1440x900 and once XRDP is launched Zoom to 200%.

.. image:: ../../pictures/udf_ubuntu_rdp_vnc.png
    :align: left
    :scale: 60%

|

Open Chrome and Postman.

For Postman, click right and click on execute (wait ~2 minutes).

.. note:: If Postman does not open, open a terminal, type ``postman`` to open postman.

.. image:: ../../pictures/postman.png
    :align: center
    :scale: 60%

|

Deploy AS3 Application Service directly to the BIG-IP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Using the declarative AS3 API, let's send the following BIG-IP configuration to BIG-IP:

Using Postman select ``BIG-IQ Token (david)`` available in the Collections.

Click right and duplicate the tab.

Replace IP address in the URL with **SEA-vBIGIP01.termmarc.com** IP address: ``10.1.1.7`` instead of BIG-IQ IP address (``10.1.1.4``).

Replace in the **body** username and password with:

  "username": "admin",
  "password": "purple123",

Press Send. This, will save the token value as _f5_token.

``Ça arrive bientôt זה בקרוב Viene pronto すぐに来る Sta arrivando presto قادم قريبا Coming soon 即將到來``

Are you interested to see a lab on this topic? `Open an issue on GitHub`_

.. _Open an issue on GitHub: https://github.com/f5devcentral/f5-big-iq-lab/issues