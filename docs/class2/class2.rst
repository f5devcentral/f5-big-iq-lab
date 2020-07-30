Class 2: BIG-IQ Deployment with auto-scale on AWS, Azure & VMware
=================================================================

In this class, we will review the auto-scale feature available with BIG-IQ 6.0 and above.
called ``Service Scaling Groups`` (SSG)

Definition of Cloud Auto-scaling
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Scalability of the infrastructure is a daily challenge for IT managers.
It is difficult to predict growth rates of applications/services and their
required resources.
Auto-scaling (or autoscaling) is a reactive method of dealing with traffic scaling.

Infrastructure scalability handles the needs of an application/service by
adding or removing resources (cpu, memory, storage, …) to maintain the SLA tied to it.
Different methods to scale an infrastructure exist:

*	Scaling down/up (also called vertical scaling)
*	Scaling in/out (also called horizontal scaling)


Auto-scaling offers the following advantages:

-	On premise, auto-scale would allow you to let servers go to sleep during low load time. This would help saving on electricity costs (potentially water cost if used for cooling)
- In the cloud, auto-scaling would help decrease the cost of the infrastructure since most of the cloud providers charge based on total usage.

Auto-scaling can offer greater uptime and more availability in cases where
production workloads are variable and unpredictable.


**Scaling up/down (vertical scaling)**

Vertical scaling is about resizing your server/virtual machine with no change
to your code. You increase/decrease the capacity by adding resources to a
single component in your infrastructure: cpu, memory, storage, ...
An example, a database needs additional resources to maintain the same level of
performance (and meet the SLAs requirements)

Scaling up an infrastructure is limited by the fact that you can only get as
big as the size of the server/virtual machine.
When this is done in the cloud, applications often get moved onto more powerful
instances and may even migrate to a different host and retire the server it was on.

These types of scale-up operations have been happening on-premises in
datacenters for decades. However, the time it takes to procure additional
recourses to scale-up a given system could take weeks or months while scaling-up
in the cloud can take only minutes.


**Scaling out/in (horizontal scaling)**

Horizontal scaling affords the ability to scale wider to deal with traffic.
It is the ability to connect multiple hardware or software entities, such as
servers/virtual machines, so that they work as a single logical unit. An
example could be to scale out from one web server system to three to handle an
increase in load.

Horizontal scaling makes it easy for service providers to offer
“pay-as-you-grow” infrastructure and services.


**Scaling up vs Scaling out**

In today’s cloud infrastructure, horizontal scaling is preferred when possible.
Instead of taking your server offline while you’re scaling up to a better one,
horizontal scaling lets you keep your existing pool of computing resources
online while adding more to what you already have. When your app is scaled
horizontally, you have the benefit of elasticity. It is easier to deploy a new
virtual system than deploying a new hypervisor.

Some other benefits are:

*	Easy to add / remove nodes to your pool of resources

  *	Cost can be tied to use. No need to pre-allocate resources, do complex capacity planning and pay for peak demand

  *	For companies running their own servers

* Unlimited scalability
*	Less expensive to configure/deploy a new virtual machine/service than buying, installing and configuring a new hypervisor in a datacenter.
*	With an horizontal scaling infrastructure, it is easier to replace unhealthy instances, handle upgrades and support some devops methodologies like AB testing, blue/green deployment.

Even if this model is appealing, it is not always a fit for all applications/services:

*	Large numbers of instances to deliver a service means increased management complexity
*	Some applications may not be a fit for a distributed computing model.

The more stateful is an application, the more difficult it will be to leverage
a scale out infrastructure for it. Micro service architecture makes it easier
to implement such a model: Loosely coupled distributed architecture allows for
scaling of each part of the architecture independently.

Labs
^^^^

.. toctree::
   :maxdepth: 1
   :glob:

   module*/module*

------------

.. include:: ../lab.rst