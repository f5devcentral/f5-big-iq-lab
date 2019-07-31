Lab 9.1: VE creation
--------------------

Prereqisites to this module:
  - Register an Enterprise Application_ on your Azure portal
  - Already have an Azure Virtual Network created
  - Have your Enterprise Application credentials available
  - Added the BIG-IP instance type to your subscription for "Programmatic Deployments"

.. Note:: VE Creation may not require the BIG-IQ and created BIG-IP's to have communication (Utility Licensing or Declarative Onboarding). The BIG-IQ is targetting the Azure public API to create these instance resources.

1. Create your BIG-IQ "Cloud Provider" for Azure

Navigate to Applications > Environments > Cloud Providers and choose **Create**

  |image01|

Fill in the Cloud Provider object with your Enterprise Application information.

  |image02|

.. Note:: If your credentials are correct you should be able to **Test** the connectivity between BIG-IQ and the Azure API.

2. Create your BIG-IQ "Cloud Environment" for Azure

Navigate to Applications > Environments > Cloud Environments and choose **Create**

  |image03|

The Cloud Environment is where our BIG-IP will be deployed. If your credentials are valid, utilizing your just created **Cloud Provider** will expose resources available to you in your Azure account.

Several parts of the Cloud Environment you may not want to configure here because you are planning on using F5 Declarative Onboarding. 
  - Device Templates are used for Service Scaling Groups, not a single or cluster of BIG-IP.
  - You must accept Programmatic Deployments for any BIG-IP you wish to deploy from the BIG-IQ interface, not doing this will result in a failure to launch.
  - Two types of Licensing, Utility will utilize the instance billing directly to the consumer, BYOL billing would be handled from a BIG-IQ License Pool, alternativly if you are planning to have F5 Declarative Onboarding do your licensing you will not specify anything.

  |image04|

2. Create your BIG-IP in Azure

Navigate to Devices > BIG-IP VE Creation > and choose **Create**

  |image05|

Fill in the Create BIG-IP VE Options.
  - Task Name will be the task (which is tracked) to deploy the BIG-IP
  - BIG-IP VE Name will be the VE Name created in Azure (not the BIG-IP TMOS name)
  - Description is a descriptive field
  - Cloud Environment is what we build it step 2
  - Number of BIG-IP VE to Create utilizing the Cloud Environment template (Only 1 can be created in Azure at a time)

  |image06|

Once all the attributes are configured **Create** the VE

  |iamge07|

BIG-IQ will gather all the needed pieces from our Provider, Environment, and Creation options. These will be send to the Azure API for building out our instance.

  |image08|

From the Azure Portal you can see the newly created instance, along with the instance BIG-IQ has created a Network Interface Card, Security Group, Storage account, and a Public IP Address.

.. Warning:: You cannot change this options at this time, a Public address will be created and the Security Group will have ports (22,8443,443,4353) open from *Any* source. If you delete the BIG-IP you will need to manually clean up the Security Group created.

  |image09|

BIG-IP VE Creation is complete from here we can see BIG-IQ harvested the Public IP address.

.. Note:: All deployments are Single-NIC so management will be on 8443

Lab 2 of this module will cover Onboarding the newly created VE.

  |image10|

.. |image01| image:: pictures/image1.png
   :width: 50%
.. |image02| image:: pictures/image2.png
   :width: 50%
.. |image03| image:: pictures/image3.png
   :width: 50%
.. |image04| image:: pictures/image4.png
   :width: 50%
.. |image05| image:: pictures/image5.png
   :width: 50%
.. |image06| image:: pictures/image6.png
   :width: 50%
.. |image07| image:: pictures/image7.png
   :width: 50%
.. |image08| image:: pictures/image8.png
   :width: 50%
.. |image09| image:: pictures/image9.png
   :width: 50%
.. |image10| image:: pictures/image10.png
   :width: 50%


.. _Application: https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal#get-application-id-and-authentication-key