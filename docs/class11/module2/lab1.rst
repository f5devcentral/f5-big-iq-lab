Lab 2.1: Configuring DoS Device Profile
---------------------------------------

The Device DoS profile reports and mitigates based on aggregated data across the entire BIG-IP. All packets that are not explicitly white listed
count for the Device DoS vectors. When using more specific profiles on Virtual Servers, the Device DoS profile should be set using values large
enough that they provide protection for the device without conflicting with Virtual Server profiles. For example individual virtual servers may be 
configured with UDP flood values to detect and mitigate values of 10000 PPS, however device DoS is set to 50000 PPS. 

.. note:: Most DoS Vector values are *per TMM*, one exception being Single Endpoint Sweep and Flood vectors which aggregates multiple packet types and applies the configured limit across all TMMs. 

The default Device DoS profile settings manual detect and mitigate are set high for all vectors. To simplify any demo, reducing these values allows for easier demonstrations. 
Additionally, if using a lab VE license there is a 10 Mb/s limit which limits how many PPS can be processed by TMM. If using larger values for DoS demonstration, use at least a 1 Gb/s license. 

For this set of labs we will be utilizing Device DoS to detect and mitigate bad packet and flood types, while using a DoS Profile to detect and mitigate 
specific DNS vectors only. This allows us to layer a fine grained DNS policy while letting Device DoS catch bad packet types across all Virtuals. 

1. Under *Configuration* > *Security* > *Shared Security* > *Device DoS Configurations*, click on *BOS-vBIGIP01*
2. Expand the *Flood* category of attack types
3. Select *UDP Flood* and modify the settings as shown below: be sure UDP port list *includes all ports* (a white listed port will not be counted, and DNS is in the default port list)

.. image:: ../pictures/module2/udp-flood-settings.png
  :align: center
  :scale: 50%


4. Click *OK* to save changes, and expand the *DNS* category of attacks
5. Select *DNS Malformed* and modify the settings as shown below then click *OK*

.. image:: ../pictures/module2/dns-malformed-settings.png
  :align: center
  :scale: 60%

6. Click *Save & Close* to save the edits
7. To deploy the changes, create and deploy using *Shared Security* or *Network Security* for *BOS-vBIGIP01* and *02*

