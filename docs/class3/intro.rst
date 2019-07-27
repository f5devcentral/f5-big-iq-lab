Introduction class 3
====================

.. warning:: When using the UDF or Ravello Lab, make sure:

  1. STOP the ESXi if you do not plan to demo VMware SSG.
  2. STOP your deployment at the end of your demo.
  3. Do not forget to tear down your AWS & Azure SSG if any.
  4. In case of demonstrating VMware SSG, use only Arizona, Virginia or Frankfurt region to get good performance.

A data collection device (DCD) is a specially provisioned BIG-IQ system that you use to manage and store alerts,
events, and statistical data from one or more BIG-IP systems.

Configuration tasks on the BIG-IP system determine when and how alerts or events are triggered on the client. The
alerts or events are sent to a BIG-IQ data collection device, and the BIG-IQ system retrieves them for your analysis.
When you opt to collect statistical data from the BIG-IP devices, the DCD periodically (at an interval that you
configure) retrieves those statistics from your devices, and then processes and stores that data.

.. image:: pictures/img_intro_1.png
  :align: center
  :scale: 50%

|

With BIG-IP Cloud Edition starting release 13.1.0.5 and above, the Analytics are being pushed from the BIG-IP to the DCDs.
Therefore, the communication between the BIG-IP and DCD needs to be bi-directional (e.g. if your BIG-IQ/DCD are on premises
the BIG-IP VE are in the public cloud such as AWS or Azure, you will need a VPN between you Datacenter and your public cloud network).
