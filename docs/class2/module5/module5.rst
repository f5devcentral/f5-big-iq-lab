Module 5: Setup a Service scaling group (SSG) in Azure
======================================================

In this module, we will learn about the ``Service Scaling Group`` (SSG) feature
provided with BIG-IQ 6.1 in a the ``Azure`` environment.

The ``Service Scaling Group`` (SSG) gives us the capability to setup a cluster of BIG-IPs
that will scale based on criterias defined by the administrator.

.. raw:: html

    <iframe width="560" height="315" src="https://www.youtube.com/embed/dDWybCsQGgY" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Service Scaling Group Topology
******************************

With BIG-IQ 6.1, the ``Service Scaling Group`` is composed of 2 tiers of ADCs.
Depending on the environment, the implementation of the ``Service Scaling Group``
(SSG) will differ.

============= ===================================== ============================
 Environment     Tier1 (called ``Service Scaler``)      Tier2 (called ``SSG``)
============= ===================================== ============================
   Azure                     ALB                                 F5 VE
============= ===================================== ============================

Tier1/``Service Scaler`` Management
***********************************

With BIG-IQ 6.1, the provisioning and deployment of Tier1 is handle automatically by BIG-IQ.


Tier2/``SSG`` Management
************************

With BIG-IQ 6.1, the provisioning of ``SSG`` BIG-IPs is fully automated. You
don't have to setup anything upfront but licenses for BIG-IQ to assign to the
dynamically provisioned BIG-IPs

To handle the provisioning and onboarding of our F5 virtual edition, we leverage
different components:

* our F5 cloud deployment templates

  * `F5 Azure template <https://github.com/F5Networks/f5-azure-arm-templates>`_

* f5 cloud libs

  * `F5 cloud libs <https://github.com/F5Networks/f5-cloud-libs>`_

.. note:: We will review this in more details in lab4

Application deployment in a ``SSG`` - Azure
*******************************************

To ensure the traffic goes through the ``SSG`` as expected, application will be
deployed in a certain manner:

* You will need dedicated ``Azure Load Balancer`` (AKA ALB previously) per
  application. The reason is that each ``ALB`` has one public IP/DNS Name
  (ie you can't have 2 app runnings on port 443/HTTPS on a ``ALB`` )
* When the app is deployed from BIG-IQ, we will specify a VS IP that will be 0.0.0.0.
  This is because ELB can only send traffic to the first nic of an instance and
  therefore we will deploy 1nic VE in Azure. So traffic and everything will be sent
  to the nic Self IP.
* This config will be configured on all ``SSG`` VEs.
  They will have an **identical** Setup

In this lab, we will create a ``Service Scaling Group`` in an ``Azure`` environment.

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
