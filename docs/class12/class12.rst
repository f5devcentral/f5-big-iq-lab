Class 11: BIG-IQ SSL Orechestrator
==================================

**[New 7.0.0]** 

``Ça arrive bientôt זה בקרוב Viene pronto すぐに来る Sta arrivando presto قادم قريبا Coming soon 即將到來``

.. toctree::
   :maxdepth: 1
   :glob:

   intro
   module*/module*
   
------------

List of Virtual Servers and Applications Servers where various type of traffic is being send to (check ``crontab`` config for more details).

+-------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Virtual IP addresses where the traffic generator sends HTTP clean traffic                 | ``10.1.10.110`` to ``10.1.10.142``                                                       |
|                                                                                           |                                                                                          |
|                                                                                           | Except ``10.1.10.117``, ``10.1.10.119`` and ``10.1.10.121`` (used for access in class 9) |
+-------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Virtual IP addresses where the traffic generator sends HTTP bad traffic                   | ``10.1.10.110`` to ``10.1.10.136``                                                       |
+-------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Virtual IP address(es) where the traffic generator sends access traffic (class 9)         | ``10.1.10.222``                                                                          |
+-------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Virtual IP addresses (listeners) where the traffic generator sends DNS traffic (class 10) | ``10.1.10.203``, ``10.1.10.204``                                                         |
+-------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Virtual IP address(es) where the traffic generator sends DDOS attack (class 11)           | ``10.1.10.136``                                                                          |
+-------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+
| Servers Applications (running in docker containers)                                       | ``10.1.20.110`` to ``10.1.20.145``                                                       |
|                                                                                           |                                                                                          |
|                                                                                           |                                                                                          |
|                                                                                           | - Port ``80``: hackazon application                                                      |
|                                                                                           | - Port ``8080``: web-dvwa application                                                    |
|                                                                                           | - Port ``8081``: f5-hello-world application                                              |
|                                                                                           | - Port ``8082``: f5-demo-httpd application                                               |
|                                                                                           | - Port ``445``: ASM Policy Validator                                                     |
+-------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------+

.. note:: IPs from ``10.1.10.110`` to ``10.1.10.142`` have a corresponding FQDN named from ``site10.example.com`` to ``site42.example.com``.


