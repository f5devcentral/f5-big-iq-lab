Module 2: BIG-IQ Application Templates & Deployment (Service Catalog)
=====================================================================
In this module, we will learn how to use BIG-IQ Service Catalog Templates and how to deploy an **Application** wtih it.

.. warning:: Starting BIG-IQ 6.1, AS3 should be the preferred method to deploy application services through BIG-IQ.

The Application Service Catalog Templates will be created by **david** (or **marco**), the Administrator.
**larry** will create the security policies and let David know about the ones to associate with the templates.
Once the template is ready with all the necessary information, it will be ready to use by the Application owner.

**paula** needs to deploy an application, she has multiple Application servers. At this time, she needs to test
the performance of her application, she also wants to make her application secure before staging it to production.
She connects to the BIG-IQ and has access to her Application Dashboard.
**paula** uses the application Service Catalog template created by David to deploy her Application.

After a week of testing her application (in the class ~5 min), she will ask **larry** to fine tune and validate
the learning done by the Application Firewall (BIG-IP ASM).

A traffic generator located on the *Ubuntu Lamp Server*, is sending good traffic every minute to the virtual servers.

Once the security policy is tuned and validated, **paula** will enforce blocking mode in the policy.

Finally, we will simulate "bad" traffic to show the security policy blocking it.

Workflows WAF service deployement with **BIG-IQ Service Catalog Template**
--------------------------------------------------------------------------

Larry create the ASM Policy in *transparent* mode (**workflow used in module 2**)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
1. Paula uses a WAF template to deploy her application service using the ASM policy created by larry.
       
   .. note:: The Domain Names she sets will be added to the hostname properties of the ASM policy (where the Policy will always be transparent for).
       
             At this point, because the policy is in transparent mode, Paula cannot turn on/off blocking for her application.
    
2. Traffic go through the Application Service and ASM learning builds up.
    
3. After some time (days or weeks), Larry reviews the learning with Paula (or without) and accepts/rejects the learning.
    
4. Once learning has been approved, Larry can update the policy and let know Paula about it.

   .. note:: In order to allow Paula to turn on/off blocking for her application, Larry needs to change the learning mode to blocking.
    
5. Paula can turn on blocking for her application, this will remove the Domain Names in the ASM policy and enforment will be applied.

Larry create the ASM Policy in *blocking* mode
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Paula use a WAF template to deploy her application service using the ASM policy created by larry.
      
   .. note:: The Domain Names she sets will be added to the hostname properties of the ASM policy (where the Policy will always be transparent for).
       
                   At this point, because the policy is in blocking mode, Paula have already the option to turn on/off blocking for her application.
    
2. Traffic go through the Application Service and ASM learning builds up.
    
3. After some time (days or weeks), Larry review the learning with Paula (or without) and accepts/rejects the learning.
    
4. Once learning has been approved, Larry can update the policy with the learning and let know Paula about it.
    
5. Paula can turn on blocking for her application, this will remove the Domain Names in the ASM policy and enforment will be applied.

For more information about ASM enforcement mode, read following article https://support.f5.com/csp/article/K67438310

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
