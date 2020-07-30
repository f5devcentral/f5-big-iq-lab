Module 11: BIG-IP Provisioning on GCP and Onboarding using AWX/Ansible Tower and BIG-IQ
=======================================================================================

This module demonstrates how Ansible can be used to automate the provisioning of BIG-IP on GCP and then onboard the device onto BIG-IQ for managing its license and device level role based access (new in 7.1):

.. Note:: You need a Google Cloud Platform (GCP) service account and credentials to complete these labs. 

The labs in this module will cover below tasks:

- Prepare GCP account credentials
- Create Regkey Pool on BIG-IQ
- Add keys to the Regkey Pool
- Deploy BIG-IP in GCP (*Currently not supported from BIG-IQ UI*)
- Onboard BIG-IP onto BIG-IQ (Discovery, Assign License, Add to existing role)
- Offboard BIG-IP from BIG-IQ (Revoke License, Remove BIG-IP from role, Remove from BIG-IQ, Delete Instance)

.. toctree::
   :maxdepth: 1
   :glob:

   lab*