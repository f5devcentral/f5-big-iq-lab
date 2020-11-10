Module 8: Declarative Onboarding and VE Creation on AWS
=======================================================

BIG-IQ Centralized Management makes it easy for you to create, configure, and manage BIG-IP VE devices in an AWS environment.

.. Note:: All deployments are Single-NIC for AWS. If you need to create additional NICs, you will need to do it
          through the cloud provider UI or API.

To start managing a BIG-IP VE device in a cloud environment, you'll need to complete the following workflows.
  - Configure your AWS Virtual Private Cloud
  - Specify your cloud provider details
  - Create your cloud environment
  - Create a BIG-IP VE device
  - Onboard your BIG-IP VE device or BIG-IP VE device cluster

.. Note:: After you save the configuration for the BIG-IP VE devices you created, BIG-IQ sends an API call to apply that configuration to the targeted BIG-IP VE devices. After BIG-IQ successfuly applies the configuration, it then discovers and imports the services the device is licensed for. This means you don't have to discover and import services in a separate step.

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
