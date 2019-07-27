Module 5: License Management
============================
A software license is specific to F5 product services (for example, BIG-IP LTM, BIG-IP APM, and so forth), and is organized in a license pool.
From BIG-IQ Centralized Management, you can easily manage licenses in those pools for numerous devices.
That means you don't have to log in to each individual BIG-IP VE device to activate, revoke, or reassign a license.

After you activate your subscription or ELA registration key for a pool license from BIG-IQ, you can assign the license to a managed, 
or unmanaged, BIG-IP VE device. If you assign a license from a license pool to a BIG-IP device and later decide you don't need that device licensed, 
you can revoke the license and assign it to another BIG-IP VE device. This process is similar to a library, where you loan (assign) a 
license to a BIG-IP device when it is required, and check the license back into the license pool on BIG-IQ (revoke it from the device) so it is available 
to assign to another BIG-IP VE. This flexible licensing model helps keep track of the licenses, and manage your operating costs.

There are 3 types of devices you can manage licenses for:

- **Managed BIG-IP devices**: From BIG-IQ, you assign licenses to and revoke license from BIG-IP devices using each device’s SSL certificate 
  for authentication over an SSL connection.
- **Unmanaged BIG-IP devices**: From BIG-IQ, you assign licenses to and revoke licenses from BIG-IP devices using each BIG-IP device’s IP address, 
  user name, and password for authentication over an SSL connection.
- **Unreachable devices**: For devices that BIG-IQ does not have network access to, a third-party computer or program communicates with BIG-IQ through 
  API calls to get a license from BIG-IQ and assign it to the BIG-IP device by a method of your choosing. The third party makes a similar API call to 
  BIG-IQ for revoking a license.
  
In this lab, we will see the difference between the various types of license pools and how to license a **Managed BIG-IP** Virtual Edition (VE) using BIG-IQ as a License Manager.

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
