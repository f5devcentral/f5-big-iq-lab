Lab 1.1: Configuring BIG-IQ for DoS Visibility
----------------------------------------------

.. note:: Estimated time to complete: **5 minutes**

As of BIG-IQ 6.0, BIG-IQ supports remote log collecting and viewing for DDoS Events. DCDs are *required* for this feature as
the BIG-IQ CM is not receiving any logs directly rather, all log messages are sent via HSL from the BIG-IP to a DCD.  The BIG-IQ CM 
views and reports on the data.

.. include:: /accesslab.rst

Tasks
^^^^^

By default, BIG-IQ CM does *not* enable this service for DoS. 
This Lab blueprint has enabled already, however to validate and enable/disable this service:

1. Log into the BIG-IQ CM.
2. Under *System* > *BIG-IQ Data Collection* > *BIG-IQ Data Collection Devices*, click *Services*.
3. Validate the *DoS Protection* services status is active (the listening port is 8020).


.. image:: ../pictures/module1/DoS-services.png
  :align: center
  :scale: 50%
