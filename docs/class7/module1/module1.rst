Module 1: Network Security Firewall Objects
===========================================
 
Network firewalls use rules and rule lists to specify traffic-handling actions.
These rules can be built-up using a number of traffic classification objects (e.g. address lists, ports lists, and geography information), 
which can be re-used across many different rules to scale a firewall policy more eloquently. 

The network software compares IP packets to the criteria specified in rules.
If a packet matches the criteria, then the system takes the action specified by the rule.
If a packet does not match any rule from the list, the software accepts the packet or passes it to the next rule or rule list.

For example, the system compares the packet to self IP rules if the packet is destined for a network associated with a self IP address that has firewall rules defined.
Rule lists are containers for rules, which are run in the order they appear in their assigned rule list.
A rule list can contain thousands of ordered rules, but cannot be nested inside another rule list.
You can reorder rules in a given rule list at any time. Ultimately, rules and rule lists objects are attached via policy to various contexts within the AFM system.
In this module, we will go through exercises for building up a firewall policy from the base objects, managing and editing these objects using the BIG-IQ, and attaching the policies to various system contexts.

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
