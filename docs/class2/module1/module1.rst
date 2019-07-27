Module 1: Setup a Service scaling group (SSG) in VMWARE
=======================================================

In this module, we will learn about the ``Service Scaling Group`` (SSG) feature
provided with BIG-IQ 6.0 in a ``VMWare`` environment

The ``Service Scaling Group`` (SSG) gives us the capability to setup a cluster of BIG-IPs
that will scale based on criterias defined by the administrator.

Topology of Service Scaling Group
---------------------------------

With BIG-IQ 6.0, the ``Service Scaling Group`` is composed of 2 tiers of ADCs.
Depending on the environment, the implementation of the ``Service Scaling Group``
(SSG) will differ.

============= ===================================== ============================
 Environment     Tier1 (called ``Service Scaler``)      Tier2 (called ``SSG``)
============= ===================================== ============================
   VMWARE                   F5 ADC                               F5 VE
============= ===================================== ============================

Tier1/``Service Scaler`` management - how does this work ?
----------------------------------------------------------

With BIG-IQ 6.0, the provisioning and deployment of Tier1 has to be done
upfront by the administrator. It means that:


* The F5 platform will have to be provisioned, licensed (for F5 VE)
  and its networking configuration done
* Once the platform is ready. everything related to app deployment will be
  handled by BIG-IQ


Tier2/``SSG`` management - how does this work ?
-----------------------------------------------

With BIG-IQ 6.0, the provisioning of ``SSG`` BIG-IPs is fully automated. You
don't have to setup anything upfront but licenses for BIG-IQ to assign to the
dynamically provisioned BIG-IPs

To handle the provisioning and onboarding of our F5 virtual edition, we leverage
different components:

* ansible playbooks to handle the provisioning of our F5 virtual edition
* our F5 cloud deployment templates

  * `F5 VMWare template <https://github.com/F5Networks/f5-vmware-vcenter-templates>`_

* f5 cloud libs

  * `F5 cloud libs <https://github.com/F5Networks/f5-cloud-libs>`_

.. note:: We will review this in more details in lab4

Application deployment in a ``SSG`` - VMWARE
--------------------------------------------

To ensure the traffic goes through the ``SSG`` as expected, application will be
deployed in a certain manner:

* When the app is deployed from ``BIG-IQ``, it will receive a Virtual server IP.
* This VS IP will be configured:

  * On all VEs part of the ``SSG``. This IP will be used to setup the relevant
    All the Virtual editions part of the ``SSG`` will have an
    **identical** Setup
  * On the tier 1/``Service Scaler`` cluster. ``BIG-IQ`` will setup a virtual server with the same IP
    and the following configuration

      * address translation will be disabled
      * the pool members for this app will be the ``SSG`` Self-IPs
      * the pool monitor will be based on the app specifications

In this lab, we will create a ``Service Scaling Group`` in a ``VMWare`` environment.


.. note::

  The VMs in vSphere aren't restarted automatically in case the deployment is stop/start in UDF.
  There is a script which restart the powerOff VMs after 15min the deployment is started ``~/f5-vmware-ssg/cmd_power_on_vm.sh``

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
