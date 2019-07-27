Lab 2.1: Service Catalog Built-in templates
-------------------------------------------
.. warning:: Starting BIG-IQ 6.1, AS3 should be the preferred method to deploy application services through BIG-IQ.

BIG-IQ v6.0 will have the default templates below built-in. These default templates cannot be modified but they can be cloned.
They can be used to deploy various type of applications. **These default templates are only displayed after BIG-IQ is managing a BIG-IP device.**

- ``Default-f5-FastL4-TCP-lb-template``: For load balancing a TCP-based application with a FastL4 profile.
- ``Default-f5-FastL4-UDP-lb-template``: For load balancing a UDP-based application with a FastL4 profile.
- ``Default-f5-HTTP-lb-template``: For load balancing an HTTP application on port 80.
- ``Default-f5-fastHTTP-lb-template``: For load balancing an HTTP-based application, speeding up connections and reducing the number of connections to the back-end server.
- ``Default-f5-HTTPS-WAF-lb-template``: For load balancing an HTTPS application on port 443 with a Web Application Firewall using an ASM Rapid Deployment policy.
- ``Default-f5-HTTPS-offload-lb-template``: For load balancing an HTTPS application on port 443 with SSL offloading on BIG-IP.
- ``Default-f5-HTTP-url-routing-lb-template``: For load balancing an HTTP application with url routing. **[New 6.1.0]** 

Connect as **david** (or **marco**), go to *Applications* > *SERVICE CATALOG*:

Look through the different default templates.

.. image:: ../pictures/module2/img_module2_lab1_1.png
  :align: center

|

.. warning:: 
    Cannot use default AWS templates to have BIG-IQ manage BIG-IP systems running 13.1.0.5 through 13.1.0.8.
    Use the following AWS templates: ``Default-AWS-f5-HTTPS-WAF-lb-template`` or ``Default-AWS-f5-HTTPS-offload-lb-template``.
    For these two templates, ports 443 and 80 (for HTTP redirect) are hard-coded in an iRule, which enable this functionality.

.. note:: Check Access Built-in templates in class 9 available from 6.0.1
