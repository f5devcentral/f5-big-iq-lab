Module 2: Role Base Access Control (RBAC)
=========================================

The following labs will get you familiar with managing Role Based Access
Control for the BIG-IP devices from BIG-IQ Centralized Management
console. There are several built-in roles shipped with BIG-IQ, but there
might be a reason you want to give a person one or set of permissions to
interact only in a clearly defined way with specific resources.

**About role-based user access**

BIG-IQ provides you with the tools you need to provide granular access
to users. You decide what BIG-IP objects a user interacts with, and how.
You use these BIG-IQ components for applying role-based user access.

|image1|

BIG-IQ 5.4 first introduced the ability to create Custom Role Types and
Resource Groups. The custom role types allow the admin to create
additional roles types. The admin can set exactly what actions are
permitted on which object types. The resource group functionality allows
the admin to dictate what objects can be acted on by a user or group.
The custom role type and resource group can be combined to create a
custom role.

Roles can be created with two different modes:

    Relaxed Mode - Users can view all objects related to the service(s)
    they have access to, but can modify only those they have explicit
    permission to. This is the default.

    Strict Mode - User can view or modify only the objects they have
    explicit permission to.

BIG-IQ® Centralized Management makes it easy for you to give users
specific permissions for access only to those BIG-IP® objects they need
to do their job. Role-based access allows you to create a custom role
with specific privileges to view or edit only those BIG-IP objects
(resources) you explicitly assign to the role.

**Pre-requisites for providing custom role-based access to an
application**

To complete this use case, you must have administrator access to BIG-IQ
and have:

-  Configured BIG-IQ.

-  Discovered a BIG-IP device and imported the LTM service.

-  Configured the SharePoint application on that BIG-IP device.

-  Configured authentication for your users. In this use case scenario,
   we use BIG-IQ local authentication.

There are several built-in roles shipped with BIG-IQ, but there might be
a reason you want to give a person one or set of permissions to interact
only in a clearly defined way with specific resources. To do that, you
need to add each of the following to BIG-IQ:

1. **Custom role type** - Select one or more services and define a set
   of permissions (read, add, edit, delete) for interacting with the
   objects associated with selected services.

2. **Custom resource group** - Select the specific type of resources you
   want to provide a user access to—for example, BIG-IP virtual servers.

3. **Custom role** - Associate this custom role with the custom role
   type and resource group you created, to combine the permissions you
   specified in the custom role type with the resources you defined for
   the custom resource group.

4. **Custom user** - Associate this user with the custom role you
   created to provide that person access and permissions to the
   resources you specified.

The first step to providing your user access to an application is to
create a **custom \ *role type*** and define a set of permissions to
specify how that role type interacts with objects that are associated
with a service. Then you can create a **resource group** that contains
the specific virtual server hosting your application so that you can
associate this role type and resource group to a role.


.. toctree::
   :maxdepth: 1
   :glob:

   lab*

.. |image1| image:: media/image1.png
   :width: 6.25000in
   :height: 2.45833in
