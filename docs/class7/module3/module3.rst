Module 3: Intrusion Prevention System (IPS)
===========================================
 
In Network Security you can configure profiles to inspect traffic for protocol inspection items. 
These protocol inspection items can include compliance checks (which look for packet formation issues), and signatures, 
to detect potentially malicious packet information.

Protocol inspection items are arranged in categories by the Services (for example, HTTP, SIP, or DNS). 
You can assign protocol inspection items individually or in groups for your managed BIG-IP devices.

You can apply your protocol inspection profile for the following objects:
   - Profile applied to a virtual server firewall policy rule
   - Profile directly applied to a context (vip-type context)

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
