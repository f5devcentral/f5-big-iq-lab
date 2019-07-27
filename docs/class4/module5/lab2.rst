Lab 5.2: Onboard BIG-IQ in AWS
------------------------------

There are different ways to onboard BIG-IQ in AWS:

1. Using the `F5 Trial Cloud Formation Template`_

This CloudFormation Template (CFT) creates two BIG-IQ VE instances:

- a BIG-IQ Centralized Management (CM) standalone instance to configure and orchestrate instances of BIG-IP VE
- a BIG-IQ Data Collection Device (DCD) to store analytics data.

2. Using the `F5 License Manager Cloud Formation Template`_

This CloudFormation Template launches and configure a standalone BIG-IQ VE or two BIG-IQ VEs in a clustered (hot-standby)
configuration across Amazon Availability Zones.


3. Using the `F5 BIG-IQ Setup Documentation`_

Follow the documentation to bring up the BIG-IQ CM and DCD in AWS.

Once the BIG-IQ VE are up and running, Ansible Galaxy Role used in Lab 1 can be used to onboard the BIG-IQ and DCD (*bigiq_onboard* and *register_dcd*)

.. _F5 Trial Cloud Formation Template: https://github.com/f5devcentral/f5-big-ip-cloud-edition-trial-quick-start
.. _F5 License Manager Cloud Formation Template: https://github.com/F5Networks/f5-aws-cloudformation/tree/master/experimental/bigiq/licenseManagement
.. _F5 BIG-IQ Setup Documentation: https://techdocs.f5.com/kb/en-us/products/big-iq-centralized-mgmt/manuals/product/big-iq-centralized-management-and-amazon-web-services-setup-6-0-0.html