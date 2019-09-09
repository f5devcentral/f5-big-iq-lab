Lab 7.2: Device Onboarding with BIG-IQ
--------------------------------------

Prerequisites to this module:
- A BIG-IP available that you would like to target with F5 Declarative Onboarding
- Connectivity to/from the BIG-IQ (CM/DCD) and the BIG-IP if you are going to onboard the BIG-IP into BIG-IQ

1. From the VE Creation in BIG-IQ, choose **Onboard**:

  |image10|

.. Note:: Although you can start BIG-IP onboarding from multiple locations, we select our VMWare instance from the VE Create screen.

2. Build our Declarative Onboarding configuration

F5 Declarative Onboarding like Application Services 3 utilizes **Classes** as configuration objects. If you were to build DO without BIG-IQ, you would need to structure the Classes into a payload that is able to be sent at a BIG-IP. From the BIG-IQ Onboard Properties screen, we can see the DO classes available to us, which will form the payload to be sent at a targeted BIG-IP.

The two main differences between DO native and BIG-IQ with DO are the **BIG-IQ Settings**, and the **License** classes. 
  - The BIG-IQ settings class is used to replace the Discovery and Import process of traditional BIG-IPs into the BIG-IQ platform.
  - The License class can be used to license the BIG-IP VE with a regKey directly or utilizing a licensePool from either the Current BIG-IQ or a different BIG-IQ

Required Parameters for DO with created VMWare instances
  - Target Host
  - Target Username
  - Target Passphrase
  - Onboard Class License
  - Onboard Class User

  |image11|

.. Warning:: If using a pool license when onboarding a BIG-IP VE device running verion 14.+, you must supply the BIG-IP admin and user names, same as the ones enterend for the ```User``` Class.

.. Warning:: In TMOS versions 14+ the root account is set to the same password as the Admin account when changed, if you do not want this specify a different password for the root account in Declarative Onboarding.

.. Note:: You do not need to have created the BIG-IP VE from BIG-IQ to send Declarative Onboarding payloads. If you did create the VE from BIG-IQ, it would show up in the BIG-IP VE drop-down list; if you did not create it, you would need to specify the Target information.

Similar to Application Templates and AS3 Templates, Declarative Onboarding has a Sample API request to see what this payload would look like being sent programmatically into the BIG-IQ.

  |image12|

With the configuration, set click the **Onboard** button.

  |image13|
  |image14|  
  |image15|


BIG-IQ will gather all the needed pieces from our DO options. These will be sent to the BIG-IP VE target API for configuring our device.

  |image16|

Once onboarding is complete, the BIG-IP VE will be a managed BIG-IP within BIG-IQ and can be used for Application and Service Deployments.

  |image17|


.. |image10| image:: pictures/image10.png
   :width: 100%
.. |image11| image:: pictures/image11.png
   :width: 100%
.. |image12| image:: pictures/image12.png
   :width: 100%
.. |image13| image:: pictures/image13.png
   :width: 100%
.. |image14| image:: pictures/image14.png
   :width: 100%
.. |image15| image:: pictures/image15.png
   :width: 100%
.. |image16| image:: pictures/image16.png
   :width: 100%
.. |image17| image:: pictures/image17.png
   :width: 100%