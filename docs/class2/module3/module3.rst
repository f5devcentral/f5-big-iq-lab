Module 3: Upgrade - Scaling up a SSG (VMWare)
=============================================

In this module, we will see how we can scale up and upgrade our ``Service Scaling Groups``
called *SSGClass2*.

In the cloud today, it is fairly easy,cheap and fast to deploy a new server. We can 
deploy/delete whatever instance in a matter of minutes instead of days with physical servers. 

Being able to deploy with ease new instances allowed administrator to shift from a 
``mutable infrastructure`` to an ``immutable infrastructure``. Instead of having to do config update, 
upgrade or add more ressources to an existing server, we simply deploy a new instance with 
all the changes. We don't change anything on a already deployed server. This is called 
``immutable infrastructure``.

In a ``immutable infrastructure``, we have servers that are never updated/changed. 
When you need to deploy a new version or change its configuration, you deploy a new server 
(or Virtual Machine/Container) that will include all the required changes.

If you want to learn more about mutable / immutable infrastructure, you may review 
some below link: 

* `Can network infrastructure be immutable infrastructure? <https://devcentral.f5.com/articles/can-network-infrastructure-be-immutable-infrastructure>`_

With ``Service Scaling Groups``, we enforce an ``immutable infrastructure`` philosophy. 
For the following use cases, we will deploy new Virtual Editions to replace existing ones: 

* Scale Up instances
* Upgrade the version used by the ``SSG``

The process is pretty straightforward: we simply need to reference a new VMWare template 
for the *Cloud Environment* used by the ``SSG``. 

.. note:: the concept and steps are the same for AWS SSG, update the *AMI Image* instead of the *VM Image*.

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
