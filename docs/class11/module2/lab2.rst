Lab 2.2: Creating and Applying a DoS Profile for a Virtual Server
-----------------------------------------------------------------

.. include:: /accesslab.rst

Tasks
^^^^^

For more granular DoS Settings, a DoS Profile can be created and applied to Virtual Servers which will then be viewed as *Protected Objects* under DoS Reporting. In this lab we will create a DoS profile for the DNS Virtual Server that detects and mitigates a sub-set of vectors at a lower rate then Device DoS. 

First we will create and edit a new DoS Profile:

1. Under *Configuration* > *Security* > *Shared Security* > *DoS Profiles*, click the *Create* button
2. Under Properties, give the profile a unique name such as *my_dos_profile*
3. Select *Protocol DNS Security* and check *DNS Protection* which enables all Attack Types to be viewed and edited
4. Enable and set the *SOA Query*, *MX Query*, and *TXT Query* Vectors for manual detection with values shown in the image below

.. image:: ../pictures/module2/dns-dos-profile.png
  :align: center
  :scale: 50%

5. Save and Close to return to the *DoS Profiles*

When using profiles on Virtual Servers, a logging profile should also be set. While different log profiles can be used, typcially the same publisher is used. Previously created only a new publisher, and set that on Device Dos. To use that same publisher on a Virtual Server, we must create a new Logging Profile and assign that publisher to it.

1. Under *Configuration* > *Security* > *Shared Security* -> *Logging Profiles* click *Create*
2. Give the profile a unique name such as *my_dos_logging_profile*
3. From the *DoS Protection* tab, set the *Status* to enabled
4. Set the Publisher to *dos-remote-logging-publisher* for *DNS DoS Protection*
5. Save and Close changes

Now that the profiles are created, we assign it to the Virtual Server and Deploy all Changes

1. Under *Configuration* > *Security* > *Shared Security* > *Virtual Servers*, click on the *dnsListenerUDP* Virtual for *BOS-vBIGIP01*
2. Set the *DoS Profile* to the newly created one
3. Set the Logging profile to the profile created above
4. Save the changes as shown in the image below

.. image:: ../pictures/module2/dns-vs-profile.png
  :align: center
  :scale: 50%


Finally deploy the changes to both *BOS* BIG-IPs via *Deployment* > *Shared Security*  

