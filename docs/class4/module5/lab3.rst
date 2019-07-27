Lab 5.3: Onboard BIG-IQ in Azure
--------------------------------

There are different ways to onboard BIG-IQ in Azure:

1. Using the `F5 Trial Azure Resource Manager Template`_

This Azure Resource Manager (ARM) creates two BIG-IQ VE instances:

- a BIG-IQ Centralized Management (CM) standalone instance to configure and orchestrate instances of BIG-IP VE
- a BIG-IQ Data Collection Device (DCD) to store analytics data.

2. Using the `F5 License Manager ARM Template`_

This Azure Resource Manager launches and configure a standalone BIG-IQ VE or two BIG-IQ VEs in a clustered (hot-standby)
configuration.


3. Using the `F5 BIG-IQ Setup Documentation`_

Follow the documentation to bring up the BIG-IQ CM and DCD in Azure.

Once the BIG-IQ VE are up and running, Ansible Galaxy Role used in Lab 1 can be used to onboard the BIG-IQ and DCD (*bigiq_onboard* and *register_dcd*)

.. _F5 Trial Azure Resource Manager Template: https://github.com/f5devcentral/f5-big-ip-cloud-edition-trial-quick-start
.. _F5 License Manager ARM Template: https://github.com/F5Networks/f5-azure-arm-templates/tree/master/experimental/bigiq/licenseManagement
.. _F5 BIG-IQ Setup Documentation: https://techdocs.f5.com/kb/en-us/products/big-iq-centralized-mgmt/manuals/product/big-iq-centralized-management-and-msft-azure-setup-6-0-0.html