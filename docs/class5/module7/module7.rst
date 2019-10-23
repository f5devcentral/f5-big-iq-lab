Module 7: Declarative Onboarding and VE Creation on VMware (7.0 and above)
==========================================================================

**[New 7.0.0]**

BIG-IQ Centralized Management makes it easy for you to create, configure, and manage BIG-IP VE devices in a VMWare environment.

To start managing a BIG-IP VE device in a cloud environment, you'll need to complete the following workflows.
  - Import the BIG-IP VE OVA for each BIG-IP version you want to use as a VMware template
  - Set the CPU number and amount of memory based on the usage and provisioning 
  - Deploy the OVA/OVF to your vCenter server. 
  - Install the VMware Tools on the template/clone
  - Verify the VMware environment is on a Datastore that is available to the ESXi host or cluster

.. Note:: The VMWare environment has already been set up for you, the above steps are for reference.

BIG-IQ supports these VMware cloud environments for auto-scaling:  
  - VMware vCenter version 6.0 (ESXi version 5.5 and 6.0)
  - VMware vCenter version 6.5 (ESXi version  6.0 and 6.5)

.. Warning:: If you identify the VE installation destination using a VMWare cluster name, the VMware host must have DRS enabled before you try to deploy the SSG, or the deployment will fail. If you use the ESXi hostname, the DRS setting is optional.

.. Note:: After you save the configuration for the BIG-IP VE devices you created, BIG-IQ sends an API call to apply that configuration to the targeted BIG-IP VE devices. After BIG-IQ successfully applies the configuration, it then discovers and imports the services the device is licensed for, this means you don't have to discover and import services in a separate step.

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
