Lab 1.1: Creating and Managing Network Firewall Objects
-------------------------------------------------------

.. note:: Estimated time to complete: **25 minutes**

.. include:: /accesslab.rst

Create Shared Firewall Objects
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

F5 Advanced Firewall Manager (AFM) configurations are built-up using a series of smaller object containers. 
For example, a firewall policy may contain one or more rule lists, which contain firewall rules in an ordered list; a rule in  a rule list may contain one or more address lists, which contain lists of addresses or networks, and/or one or more port lists, which contain lists of ports.  Building firewall policies through a series of smaller building blocks, allows for object re-use across all firewall objects, and when managed through BIG-IQ allows for simple re-use of firewall objects across an entire fleet for F5 AFM instances.  In this excercise, we will create a few shared objects to be used in subsequent exercises for building a firewall policy.

.. note:: All steps in this lab will be completed using the persona Larry.


**Create Address Lists**:

#. Connect to your BIG-IQ (as *Larry*)and go to : *Configuration* > *Security* > *Network Security* > *Address Lists*
#. Click *Create* to create a new address list 
#. Edit the *Name* field, using the name ``deployed_app_destinations``
#. Click the *Addresses* button on left side of screen
#. Click the *Type* field to review the available options, then select *Address*
#. Add the address 10.1.10.136, and use site36 in the description
#. Click *Update*, then click *Save & Close* from bottom right

Create another address list identifying some known bad sources to block (small subset for Spamhaus EDROP):

#. Repeat steps 1-3 from above, this time using name ``deployed_app_bad_sources``
#. Click the *Addresses* button on left side of screen
#. Add the following to the address list
   - 5.188.11.0/24; description = Spamhaus EDROP member
   - 5.188.216.0/24; description = Spamhaus EDROP member
   - 14.118.252.0/22; description = Spamhaus EDROP member
   - Geolocation = Russian Federation; description = block those Russians

   .. note:: Above sources are just being used for purpose of example.  Spamhaus EDROP list contains many more entries, and Russians aren't that bad!

#.  Click *Save & Close*

**Create a Port List**:

#. Under *Configuration* > *Security* > *Network Security* >, click *Port List*
#. Click *Create* to create a new port list
#. Edit the *Name* field, using the name ``deployed_app_ports``
#. Click the *Ports* button on left side of the screen
#. Click the *Type* field too review the available options, the select *Port*
#. In the *Ports* field type ``80``, the click the + symbol, and add port ``443``
#. Click *Update*, then click *Save & Close* from the bottom right


Create Firewall Rules using Shared Firewall Objects
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Network firewalls use rules and rule lists to specify traffic-handling actions. The network software compares IP packets to the criteria specified in rules. If a packet matches the criteria, then the system takes the action specified by the rule. If a packet does not match any rule from the list, the software accepts the packet or passes it to the next rule or rule list. For example, the system compares the packet to self IP rules if the packet is destined for a network associated with a self IP address that has firewall rules defined.

Rule lists are containers for rules, which are run in the order they appear in their assigned rule list. A rule list can contain thousands of ordered rules, but cannot be nested inside another rule list. You can reorder rules in a given rule list at any time.

**Create Firewall Rule**:

#. Under *Configuration* > *Security* > *Network Security* > *Rule Lists*
#. Click *Create* to create a new rule list
#. Edit the *Name* field, using the name ``deployed_app_filters``
#. Click the *Rules* button left side of the screen
#. Click *Create Rule*
#. Click the pencil next to the new rule and edit as follows:
   - Name = bad_app_sources
   - Source Address = Address List = deployed_app_bad_sources
   - Action = drop 
   - Log = Check box to enable logging
   - Leave all other fields as any.
#. Click *Update* next to new rule.
#. Click *Create Rule*
#. Click the pencil next to the new rule and edit as follows:
   - Name = deployed_app_dests 
   - Destination Address = Address List = deployed_app_destinations
   - Destination Ports = deployed_app_ports
   - Protocol = TCP
   - Action = Accept 
   - Leave all other fields as any
#. Click *Save & Close*

**Manipulating Rules in Rules Lists**:

In this section, we will experiment with the various methods of re-ordering, editing, copying, and remove rules and rule contents

#. From the Rule List screen, click on the ``deployed_app_filters`` rule list we just created, and experiment with options for manipulating the rules in the rules list:
   - Drag the ``deployed_app_dests`` rule and drop it above the ``deployed_app_bad_sources`` rule
   - Right click the ``deployed_app_dests`` rule and examine the available options.  Select *Cut Rule*, then select the ``bad_app_sources`` rule, right click and select *Paste After*
   - Right click the ``deployed_app_bad_sources`` and select *Copy Rule*
#. Click *Cancel*, the click *Create* from Rule List screen
#. Click *Rules*, then *Create Rule*
#. Right click newly created rule, and select *Paste Before*.  The rule we copied from the ``deployed_app_filters`` has now been inserted in our new rule list.

   .. note:: You can use Copy Rule and then Paste Rule between rule lists.  However, if you use the Cut Rule option and then paste betweeen rule lists, the cut rule will not be removed from the rule list.

#. Click the pencil next the rule you just inserted to edit the rule.  Click the "x" next to the ``deployed_app_destinations`` and ``deployed_app_ports`` lists to clear these fields from the rule.

   .. note:: When editing a rule not all fields can be cleared, but you can remove the contents of the following fields:
   
   - Address (source or destination)
   - Port (source or destination)
   - VLAN
   - iRule
   - Description

#. Right click the rule initially created when you clicked *Create Rule*, and select *Delete Rule*
#. Click *Cancel* to exit rule list editor

**Managing Rule Lists**:

In this section, we will work with various options for managing rule lists

#. From the Rule List screen, select the ``deployed_app_filters`` rule list, and click the *Clone* button
   - Cloned rules provide a simple mechanism for copying an entire rule list, and making simple edits for new requirements.
#. Edit the Properties and Rules sections to meet new requirements.  For this lab, just go ahead and give the cloned rule a new name.  If you select a different partition in the cloned rule list, that partition must already exist on the BIG-IPs that the configuration will be deployed on.
#. Click *Save & Close* to save the newly cloned rule.  The cloned rule list is added to alphabetically under Rule Lists.  In a high availability configuration, the cloned rule list is replicated to the standby system as soon as it is cloned.
#. Click the cloned rule list.  In the bottom on the screen, view the elements of the rule list in the left hand pane.  In the right hand pane, click the *Related Items* button.  This will show you the objects related to the rule list, and the application components that are using the rule list.
#. Click the *Delete* button.  In this case, our cloned rule list isn't being used, so it is safe to delete.  If, however, the rule list was in use BIQ would present a dialog box informing you that you cannot remove the rule list because it is in use.

Create Firewall Policy, Publish, and Assign to Context
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ultimately, the rule lists we worked with in the previous section are associated with a firewall policy for deployment.  Firewall policies, can be attached in multiple contexts (Global, Route Domain, Virtual Server, Self IP, and Management IP).  In this lab, we will explore using BIG-IQ to create a firewall policy, and look at options for attaching the policy in various contexts.  Finally, we will publish our firewall policy, and assign it to an application template.

**Creating Firewall Policies**:

#. Under *Configuration* > *Security* > *Network Security*, click *Firewall Policies*
#. Click *Create* to create a new firewall policy
#. Give the policy the name ``f5-afm-policy_136``, and click *Rules* button
#. Click *Add Rule List* button, and select the ``deployed_app_filters`` rule list created previously, and click Add.
#. The ``deployed_app_filters`` rule list will be added to the firewall policy, named as ``Reference_To_deployed_app_filters``.  From here, you can click the carrot beneath the rule ID and see the details of the rules that are part of the associated rule lists.
#. At the bottom on the Policy Editor screen, look at the Shared Objects view.  Click the drop down to see what Shared Objects can be added to a firewall policy.  
#. Select Rule Lists form the Shared Objects drop down.  Drag the ``deployed_app_filters`` rule list into the policy.
   - Rule Lists can be added using *Add Rule List* button, or just pulled in using the Shared Object repository.
#. Right click the duplicate reference to the ``deployed_app_filters`` rule list we just added.  
#. Examine the options for manipulating the ordering or rules or rule lists inside a firewall policy.
#. Select *Delete* to remove our duplicate reference.
#. Click the *Create Rule* button to add a new rule to the firewall policy
   - Firewall policies contain and ordered list of rules and rules lists.  Using rule lists is a good method for organizing larger sets of rules, but not a requirement for building a firewall policy.
#. Click the pencil next to the new rule to edit the rule.
#. From the *Shared Objects* pane at the bottom on the Policy Editor screen, select *Address Lists* from the drop down.
#. Drag the address list ``deployed_app_bad_sources`` into the source address field in the rule we are editing.
   - Address and Port lists can be dragged into rules inside firewall policy editor in the same way they can in rule list editor.
#. Click *Update*
#. Right click the rule you just added and select *Delete*
#. Click *Save and Close* to create the new firewall policy.


**Associating Firewall Policies with Contexts**:

As mentioned, firewall policies can be attached to various contexts within a BIG-IP system.  Namely, policies can be attached at the Global, Route Domain, Virtual Server, Self-IP, and Management contexts.  In these exercises, we will explore using BIG-IQ to make these associations:

#. Under *Configuration* > *Security* > *Network Security*, click *Contexts*
#. In the search bar in the upper right corner, search for global.
#. Click the global context for the device ``SEA-vBIGIP01.termmarc.com``
#. Examine the *Properties* page.  A firewall policy can be attached as an *Enforced Firewall Policy* or a *Staged Firewall Policy*
#. From the *Shared Objects* section on bottom of screen, select *Firewall Policies*
#. Drag the ``f5-afm-policy_136`` policy into the row for *Enforced Firewall Policy*
   - Shared objects (Firewall Policies, Service Policies, NAT Policies) can be dragged and dropped into the context.
#. Click *Cancel*
#. Clear the filter for Global. If interested, you can repeat the above steps for Self-IP, Route Domain, and/or VIP.

.. note:: To this point in the lab, we have not actually deployed any configuration to BIG-IP's.  All of our configuration has been created exclusively on BIG-IQ.  You can create a deployment now to push the objects that we have created, but we will do this as part of an application template update in a subsequent step.









