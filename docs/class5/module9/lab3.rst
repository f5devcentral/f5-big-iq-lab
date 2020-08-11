Lab 9.3: Device Onboarding with BIG-IQ
--------------------------------------

.. note:: Estimated time to complete: **15 minutes**

.. include:: /accesslab.rst

Tasks
^^^^^
Prerequisites to this module:
  - A BIG-IP available that you would like to target with F5 Declarative Onboarding
  - Connectivity to/from the BIG-IQ (CM/DCD) and the BIG-IP if you are going to onboard the BIG-IP into BIG-IQ

BIG-IP onboarding can be started from two locations in BIG-IQ. From a newly created VE, you can choose to onboard right away. Alternatively, you can use the **BIG-IP Onboarding** menu option.

From the VE Creation in BIG-IQ:

  |image11|

From the BIG-IP Onboarding Menu:

  |image12|

Choosing either method will take you to the correct Onboarding interface.

.. Note:: You do not need to have created the BIG-IP VE from BIG-IQ to send Declarative Onboarding payloads. If you did create the VE from BIG-IQ, it would show up in the BIG-IP VE drop-down list; if you did not create it, you would need to specify the Target information.

1. For the Onboarding Menu option Navigate to Devices > BIG-IP Onboarding > and choose **Create**

F5 Declarative Onboarding like Application Services 3 utilizes **Classes** as configuration objects. If you were to build DO without BIG-IQ, you would need to structure the Classes into a payload that is able to be sent at a BIG-IP. From the BIG-IQ Onboard Properties screen, we can see the DO classes available to us, which will form the payload to be sent at a targeted BIG-IP.

  |image13|

The two main differences between DO native, and BIG-IQ with DO, are the **BIG-IQ Settings**, and the **License** classes. 
  - The BIG-IQ settings class is used to replace the Discovery and Import process of traditional BIG-IPs into the BIG-IQ platform.
  - The License class can be used to license the BIG-IP VE with a regKey directly or utilizing a licensePool from either the Current BIG-IQ or a different BIG-IQ

2. Build our Declarative Onboarding configuration

Our VE created in the previous lab was a single instance with 1-NIC and a BYOL license. 
From our perspective, DO doesn't need many options, BIG-IQ management, ASM / AVR provisioned, and a License. 
Then it will be ready for AS3 or Application Templates.

Check the BIG-IQ Settings and Provision options to add the class to our configuration, 
our newly created BIG-IP VE has never been configured with any configuration so we can leave the default 
options for the BIG-IQ Settings class. Add in our demo hostname, under-provisioning make sure that AVR and AWAF are configured with nominal.

.. warning:: In the License class, the Hypervisor needs to be selected only if reachable = false.

|image16|
|image23|
|image17|
|image26|

.. Note:: Azure does not require the use of an SSH key to log into the instance to be configured.

Similar to Application Templates and AS3 Templates, Declarative Onboarding has a Sample API request to see what this payload would look like being sent programmatically into the BIG-IQ.

  |image20|

3. Onboard BIG-IP

With the configuration, set click the **Onboard** button.

  |image18|

BIG-IQ will gather all the needed pieces from our DO options. These will be sent to the BIG-IP VE target API for configuring our device.

  |image19|

Once onboarding is complete, the BIG-IP VE will be a managed BIG-IP within BIG-IQ and can be used for Application and Service Deployments.

  |image24|

.. Warning:: In case you get following error: *"Task Failed: Failed to complete onboarding task: Unexpected response from declartive onboarding: code: 404, message: Please confirm Declartive Onboarding (DO) is running on BIG-IQ. See log for details."*, restart restnoded on the BIG-IQ CM. SSH the BIG-IQ CM server and execute ``bigstart restart restnoded``.

.. |image11| image:: pictures/image11.png
   :width: 60%
.. |image12| image:: pictures/image12.png
   :width: 60%
.. |image13| image:: pictures/image13.png
   :width: 60%
.. |image14| image:: pictures/image14.png
   :width: 60%
.. |image15| image:: pictures/image15.png
   :width: 60%
.. |image16| image:: pictures/image16.png
   :width: 100%
.. |image17| image:: pictures/image17.png
   :width: 100%
.. |image18| image:: pictures/image18.png
   :width: 50%
.. |image19| image:: pictures/image19.png
   :width: 60%
.. |image20| image:: pictures/image20.png
   :width: 60%
.. |image23| image:: pictures/image23.png
   :width: 100%
.. |image24| image:: pictures/image24.png
   :width: 50%
.. |image25| image:: pictures/image25.png
   :width: 50%
.. |image26| image:: pictures/image26.png
   :width: 100%

