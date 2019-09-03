Lab 2.4: Integrating Venafi with BIG-IQ for Certificate Management
------------------------------------------------------------------

**[New 7.0.0]**

F5 Networks and Venafi have partnered to provide a tightly-integrated solution for certificate and key management.
Managing Venafi certificate requests through BIG-IQ automates laborious processes and reduces the amount of time you 
have to spend requesting and distributing certificates and keys to your managed devices. 

- BIG-IQ can connect to Venafi under the 3rd Party CA management section.
- BIG-IQ can pull the list of policy folders from the Venafi device.
- BIG-IQ can create a CSR, choosing Venafi and a particular policy folder, send that CSR to Venafi and retrieve the cert and key data.
- BIG-IQ can match the metadata that we have from the BIG-IP devices that are managed with certificate and key data that is stored 
  on the Venafi and import that cert and key data into the BIG-IQ for deployment to BIG-IP(s) (Certs go from unmanaged to managed on BIG-IQ)
- BIG-IQ can renew a cert, choosing Venafi and a particular policy folder, send that CSR to Venafi and retrieve the cert and key data.

.. warning:: 

   In 7.0, BIG-IQ does not detect/sync changes made on Venafi itself. Also the BIG-IQ doesn't push the certs to BIG-IP automatically, 
   and it does not automatically disconnect the Venafi from pushing to certs to the BIG-IPs directly.

More information in Knowledge Center > `BIG-IQ Centralized Management: Integrating Venafi with BIG-IQ for Certificate Management`_.

.. _`BIG-IQ Centralized Management: Integrating Venafi with BIG-IQ for Certificate Management`: https://techdocs.f5.com/en-us/bigiq-7-0-0/integrating-venafi-for-certificate-management.html

