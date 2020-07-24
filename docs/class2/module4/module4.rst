Module 4: Setup a Service scaling group (SSG) in AWS
====================================================

In this module, we will learn about the ``Service Scaling Group`` (SSG) feature
provided with BIG-IQ 6.0 in a the ``AWS`` environment.

The ``Service Scaling Group`` (SSG) gives us the capability to setup a cluster of BIG-IPs
that will scale based on criterias defined by the administrator.

.. raw:: html

    <iframe width="560" height="315" src="https://www.youtube.com/embed/YByW7Q3jAvQ" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Topology of AWS Service Scaling Group
*************************************

With BIG-IQ 6.0, the ``Service Scaling Group`` is composed of 2 tiers of ADCs.
Depending on the environment, the implementation of the ``Service Scaling Group``
(SSG) will differ.

============= ===================================== ============================
 Environment     Tier1 (called ``Service Scaler``)      Tier2 (called ``SSG``)
============= ===================================== ============================
   AWS                       ELB                                 F5 VE
============= ===================================== ============================

AWS Tier1/``Service Scaler`` management - how does this work ?
**************************************************************

With BIG-IQ 6.0, the provisioning and deployment of Tier1 has to be done
upfront by the administrator. It means that:

* The AWS ELB will have to be provisioned

AWS Tier2/``SSG`` management - how does this work ?
***************************************************

With BIG-IQ 6.0, the provisioning of ``SSG`` BIG-IPs is fully automated. You
don't have to setup anything upfront but licenses for BIG-IQ to assign to the
dynamically provisioned BIG-IPs

To handle the provisioning and onboarding of our F5 virtual edition, we leverage
different components:

* our F5 cloud deployment templates

  * `F5 AWS template <https://github.com/F5Networks/f5-aws-cloudformation>`_

* f5 cloud libs

  * `F5 cloud libs <https://github.com/F5Networks/f5-cloud-libs>`_

.. note:: We will review this in more details in lab4

Application deployment in a ``SSG`` - AWS
*****************************************

To ensure the traffic goes through the ``SSG`` as expected, application will be
deployed in a certain manner:

* You will need dedicated ``Classic Load Balancer`` (AKA ELB previously) per
  application. The reason is that each ``ELB`` has one public IP/DNS Name
  (ie you can't have 2 app runnings on port 443/HTTPS on a ``ELB`` )
* When the app is deployed from BIG-IQ, we will specify a VS IP that will be 0.0.0.0.
  This is because ELB can only send traffic to the first nic of an instance and
  therefore we will deploy 1nic VE in AWS. So traffic and everything will be sent
  to the nic Self IP.
* This config will be configured on all ``SSG`` VEs.
  They will have an **identical** Setup

In this lab, we will create a ``Service Scaling Group`` in an ``AWS`` environment.

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
