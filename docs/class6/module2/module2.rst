Module 2: SSL Certificate Management
====================================

**Goal:**

In this lab, you will be able to manage the BIG-IP local traffic SSL certificates from BIG-IQ. 

From one centralized location, BIG-IQ makes it easy for you to request,
import, and manage CA-signed SSL certificates, as well as import signed
SSL certificates, keys, and PKCS #12 archive files created elsewhere.
And if you want to create a self-signed certificate on BIG-IQ for your
managed devices, you can do that too.

SSL certificates will come in two flavors, managed or unmanaged. When
BIG-IQ discovers a BIG-IP, it is only able to pull the metadata about a
cert from the BIG-IP. This process completes the cert and key
information on the BIG-IQ, so that BIG-IQ can fully manage the
discovered certs.

Once you've imported or created an SSL certificate and keys, you can
assign them to your managed devices by associating them with a Local
Traffic Manager clientssl or serverssl profile, and deploying it.

.. note::

   When you discover a BIG-IP device, BIG-IQ Centralized Management imports its SSL certificates 
   properties (metadata), but not the actual SSL certificates and key pairs. 
   These certificates display as Unmanaged on the BIG-IQ Certificates & Keys screen.
   This allows you to monitor each SSL certificate\'s expiration date from BIG-IQ, without 
   having to log on directly to the BIG-IP device.

Convert an unmanaged SSL key certificate and key pair to managed so you
can centrally manage it from BIG-IQ Centralized Management. This saves
you time because you don't have to log on to individual BIG-IP devices
to create, monitor, or deploy certificates.

.. toctree::
   :maxdepth: 1
   :glob:

   lab*
