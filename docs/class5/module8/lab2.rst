Lab 9.2: VE creation
--------------------

Prerequisites to this module:
  - An AWS account with full access permissions for the following AWS resources
    - Auto Scale Groups
    - Instances
    - SQS
    - S3
    - CloudWatch
    - CloudFormation
  - IAM role/rolePolicy/InstanceProfile with
    - List
    - Create
    - Delete 

.. Note:: VE Creation may not require the BIG-IQ and created BIG-IP's to communicate (Utility Licensing or Declarative Onboarding). The BIG-IQ will target the public AWS API for VE Creation, and the BIG-IP VE public IP for Onboarding.

1. Create your BIG-IQ "Cloud Provider" for AWS

Navigate to Applications > Environments > Cloud Providers and choose **Create**

  |image01|

Fill in the Cloud Provider object with your Enterprise Application information.

  |image02|

.. Note:: If your credentials are valid, you should be able to **Test** the connectivity between BIG-IQ and the AWS API.

2. Create your BIG-IQ "Cloud Environment" for AWS

Navigate to Applications > Environments > Cloud Environments and choose **Create**

  |image03|

The Cloud Environment is where our BIG-IP will be deployed. If your credentials were valid, utilizing your just created **Cloud Provider** will expose resources available to you in your AWS account.

Several parts of the Cloud Environment you may not want to configure here because you are planning on using F5 Declarative Onboarding. 
  - Device Templates are used for Service Scaling Groups, not a single or cluster of BIG-IP.
  - You must accept Programmatic Deployments for any BIG-IP you wish to deploy from the BIG-IQ interface, not doing this will result in a failure to launch.
  - Two types of Licensing, Utility will utilize the instance billing directly to the consumer, BYOL billing would be handled from a BIG-IQ License Pool. Alternatively, if you are planning to have F5 Declarative Onboarding specify a license, you will not define anything

For this lab, we are going to choose a simple BYOL deployment of a BIG-IP Per-app VE.

+----------------------------+------------------------------------------------------------------------------+
| Cloud Environment Settings |                                                                              |
+============================+==============================================================================+
| Name                       | AWS_Cloud_Environment                                                        |
+----------------------------+------------------------------------------------------------------------------+
| Description                |                                                                              |
+----------------------------+------------------------------------------------------------------------------+
| Device Template            | None                                                                         |
+----------------------------+------------------------------------------------------------------------------+
| Cloud Provider             | AWS_Cloud_Provider                                                           |
+----------------------------+------------------------------------------------------------------------------+
| Location                   | East US                                                                      |
+----------------------------+------------------------------------------------------------------------------+
| License type               | BYOL                                                                         |
+----------------------------+------------------------------------------------------------------------------+
| BIG-IP Image Name          | f5-big-ip-per-app-ve-awf-byol                                                |
+----------------------------+------------------------------------------------------------------------------+
| Services to Deploy         | Local Traffic + Web Application Security + Advanced Visibility and Reporting |
+----------------------------+------------------------------------------------------------------------------+
| Instance Type              | Standard_DS4_v2                                                              |
+----------------------------+------------------------------------------------------------------------------+
| Restricted Source Address  | *                                                                            |
+----------------------------+------------------------------------------------------------------------------+
| VNet Name                  | vnet1demo | (Your Prefix Resource Group)                                     |
+----------------------------+------------------------------------------------------------------------------+
| Management Subnet          | subnet1demo                                                                  |
+----------------------------+------------------------------------------------------------------------------+

Once you have the Environment setup complete, **Save & Close**

  |image21|

3. Creating your BIG-IP in AWS

Navigate to Devices > BIG-IP VE Creation > and choose **Create**

  |image05|

Fill in the Create BIG-IP VE Options.

.. Note:: You **MUST** accept the terms of the instance in AWS before you can launch the image. https://aws.amazon.com/marketplace/pp?sku=sxmg2kgwdu7h1ptwzl9d8e4b

+-------------------------------+---------------------------+
| BIG-IP VE Creation            |                           |
+===============================+===========================+
| Task Name                     | Deploy BIG-IP VE in AWS   |
+-------------------------------+---------------------------+
| BIG-IP VE Name                | bigipvm01                 |
+-------------------------------+---------------------------+
| Description                   | Created with BIG-IQ       |
+-------------------------------+---------------------------+
| Cloud Environment             | demo-7424-aws-environment |
+-------------------------------+---------------------------+
| Number of BIG-IP VE to Create | 1                         |
+-------------------------------+---------------------------+

  |image06|

Once all the attributes are configured **Create** the VE.

  |image07|

BIG-IQ will gather all the needed pieces from our Provider, Environment, and Creation options. These will be sent to the AWS API for building out our instance.

  |image08|

From the AWS Portal, you can see the newly created instance, along with the instance BIG-IQ has created a Network Interface Card, Security Group, Storage Account, and a Public IP Address.

  |image09|

.. Warning:: You cannot change these options at this time, a Public address will be created, and the Security Group will have ports (22,8443,443,4353) open from *Any* source. If you delete the BIG-IP, you will need to manually clean up the Security Group created.

BIG-IP VE Creation is complete from here we can see BIG-IQ harvested the Public IP address.

.. Note:: All deployments are Single-NIC, so management will be on 8443

Lab 2 of this module will cover Onboarding the newly created VE.

  |image10|

.. |image01| image:: pictures/image1.png
   :width: 75%
.. |image02| image:: pictures/image2.png
   :width: 75%
.. |image03| image:: pictures/image3.png
   :width: 50%
.. |image04| image:: pictures/image4.png
   :width: 85%
.. |image05| image:: pictures/image5.png
   :width: 75%
.. |image06| image:: pictures/image6.png
   :width: 50%
.. |image07| image:: pictures/image7.png
   :width: 50%
.. |image08| image:: pictures/image8.png
   :width: 90%
.. |image09| image:: pictures/image9.png
   :width: 50%
.. |image10| image:: pictures/image10.png
   :width: 90%
.. |image21| image:: pictures/image10.png
   :width: 80%


.. _Enterprise_Application: https://docs.microsoft.com/en-us/AWS/active-directory/develop/howto-create-service-principal-portal