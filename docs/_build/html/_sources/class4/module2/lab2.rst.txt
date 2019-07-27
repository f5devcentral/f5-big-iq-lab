Lab 2.2: Create a resource group and associate it with a role type
------------------------------------------------------------------

Create a resource group with all of the BIG-IP objects you want to provide access to, and assign a role type to it.

|image6|

Steps for Module 2:
^^^^^^^^^^^^^^^^^^^

1. Click ROLE MANAGEMENT > Resource Groups on the left navigation area.

2. Near the top of the screen, click the Add button.

3. In the Name field, type a name to identify this group of resources,
   from the Role Type list, select the role type you want to provide
   access to for this group of resources.

    Name: **NsresGroup**

    | Description: **Network Security Resource Group**
    | Role Type: **MyNetworkSecurityRole**

1. From the Select Service list, select the service(s) you want to
   provide access to for this group of resources. From the Object
   Type list, select the type of object you want to add to this group of
   resources.

   | Select Service: **Network Security (AFM)**
   | Select Object Type: **Firewall Policies**

2. For the Source setting, leave the default “Source: Selected
   Instances” unchanged.

   -  Selected Instances - Select this option to put only the source
      objects you selected into this resource group. If you select this
      option, the associated role will not have access to any new
      objects of the same type added in the future unless you explicitly
      add it to this resource group.

   -  Any Instance - Select this option if you want the associated role
      to have any instance of the specified object type, including
      future instances (newly configured objects of this type).

3. Select the check box next to the name of each object you want to add
   to this group of resources and click the Add Selected button.

|image7|

4. Click the Save & Close button.

Next, you can create a custom role and associate this role type and
resource group to the new role.

.. |image6| image:: media/image6.png
   :width: 6.25000in
   :height: 0.79167in
.. |image7| image:: media/image7.png
   :width: 6.48750in
   :height: 2.96250in
