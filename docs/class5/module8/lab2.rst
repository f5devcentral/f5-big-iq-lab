Lab 8.2: AWS BIG-IP VE Creation
-------------------------------

Prerequisites to this module:
  - Run the script creation file at the end of the previous lab

An AWS account with full access permissions for the following AWS resources
  - Auto Scale Groups
  - Instances
  - SQS
  - S3
  - CloudWatch
  - CloudFormation

IAM role/rolePolicy/InstanceProfile containing
  - List
  - Create
  - Delete 

.. Note:: VE Creation may not require the BIG-IQ and created BIG-IP's to communicate (Utility Licensing or Declarative Onboarding). 
          The BIG-IQ targets the public AWS API for VE Creation and the BIG-IP VE public IP for Onboarding.

1. Verify your BIG-IQ "Cloud Provider" for AWS

Navigate to Applications > Environments > Cloud Providers

  |image02|

View the Cloud Provider object with your AWS ephemeral account information.

  |image16|

2. Verify your BIG-IQ "Cloud Environment" for AWS

Navigate to Applications > Environments > Cloud Environments

  |image03|

The Cloud Environment is where our BIG-IP will be deployed. If your credentials were valid, utilizing your just created **Cloud Provider** will expose resources available to you in your AWS account.

Several parts of the Cloud Environment you may not want to be configured because you are planning on using F5 Declarative Onboarding. 
- Device Templates are used for Service Scaling Groups, not a single or cluster of BIG-IP.
- You must accept Programmatic Deployments for any BIG-IP you wish to deploy from the BIG-IQ interface, not doing this will fail to launch.
- Two types of Licensing, Utility will utilize the instance billing directly to the consumer, BYOL billing would be handled from a BIG-IQ License Pool. Alternatively, if you are planning to have F5 Declarative Onboarding specify a license, you will not define anything

3. Creating your BIG-IP in AWS

Navigate to Devices > BIG-IP VE Creation > and choose **Create**

  |image04|

Fill in the Create BIG-IP VE Options.

.. Note:: You **MUST** accept the terms of the instance in AWS before you can launch the image. Accept the EULA here_

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

Once all the attributes are configured **Create** the VE.

  |image05|

BIG-IQ will gather all the needed pieces from our Provider, Environment, and Creation options. These will be sent to the AWS API for building out our instance.

  |image06|

By logging into the AWS Console with your ephemeral account, you can see the newly created EC2 instances. BIG-IQ has also created a Network Interface Card, Security Group, Storage Account, and a Public IP Address.

  |image08|

.. Warning:: You cannot change these options at this time, a Public address will be created, and the Security Group will have ports (22,8443,443,4353) open from *Any* source. If you delete the BIG-IP, you will need to manually clean up the Security Group created.

BIG-IP VE Creation is complete from here we can see BIG-IQ harvested the Public IP address.

  |image07|

.. Note:: All deployments are Single-NIC so that management will be on 8443. If you need to create additional NICs, you will need to do it
          through the cloud provider UI or API.

Lab 2 of this module will cover Onboarding the newly created AWS VE.

.. Note:: If you try to open BIG-IP web interface, to bypass the Google Chrome “Your connection is not private” Warning, just type in blindly ``thisisunsafe``.

See `Class 2 Module 4 Lab 6`_ for help with Troubleshooting.

.. _Class 2 Module 4 Lab 6: ../../class2/module4/lab6.html

.. |image02| image:: pictures/image2.png
   :width: 60%
.. |image03| image:: pictures/image3.png
   :width: 50%
.. |image04| image:: pictures/image4.png
   :width: 60%
.. |image05| image:: pictures/image5.png
   :width: 60%
.. |image06| image:: pictures/image6.png
   :width: 50%
.. |image07| image:: pictures/image7.png
   :width: 50%
.. |image08| image:: pictures/image8.png
   :width: 60%
.. |image16| image:: pictures/image16.png
   :width: 50%


.. _here: https://aws.amazon.com/marketplace/pp?sku=sxmg2kgwdu7h1ptwzl9d8e4b