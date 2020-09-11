Getting Started
===============

Starting the Lab
----------------

In order to complete this lab, you will find 2 ways to access the different systems in this lab:
   - From the Jump Host
      From the lab environment, launch a remote desktop session to access the Jump Host (Ubuntu Desktop). 
      To do this, in your lab deployment, click on the *ACCESS* button of the **Ubuntu Lamp Server** system and click on
      *noVNC*. The password is ``purple123``.

      |

      You can also use *XRDP* as an alternative, click on the resolution that works for your laptop. 
      When the RDP session launches showing *Session: Xorg*, simply click *OK*, no credentials are needed.
      Modern laptops with higher resolutions you might want to use 1440x900 and once XRDP is launched Zoom to 200%.

      |
      
      |udf_ubuntu_rdp_vnc|

   - Going directly to the BIG-IQ CM or BIG-IP TMUI or WEB SHELL/SSH
      To access the BIG-IQ directly, click on the *ACCESS* button under **BIG-IQ CM**
      and select *TMUI*. The credentials to access the BIG-IQ TMUI are ``david/david`` and ``paula/paula`` as directed in the labs.

      |udf_bigiq_tmui|

      To ssh into a system, you can click on *WEB SHELL* or *SSH* (you will need your ssh keys setup in the lab environment for SSH).

      |    

      You can also click on *DETAILS* on each component to see the credentials (login/password).

.. |udf_ubuntu_rdp_vnc| image:: /pictures/udf_ubuntu_rdp_vnc.png
   :scale: 60%

.. |udf_bigiq_tmui| image:: /pictures/udf_bigiq_tmui.png
   :scale: 60%

BIG-IQ User Interface
---------------------

Once you connect to BIG-IQ, you can navigate in the following tabs:

- **Applications** - Application Management (Legacy, AS3) and Cloud Environement
- **System** - Manage all aspects for BIG-IQ and DCDs.
- **Devices** - Discover, Import, Create, Onboard (DO) and Manage BIG-IP devices.
- **Deployment** - Manage evaluation task and deployment for Configuration Management (none AS3)
- **Configuration** - ADC and Security Object Management (ASM, AFM, APM, DDOS, SSLo config/monitoring)
- **Monitoring** - Event collection per device, statistics monitoring, iHealth reporting integration, alerting, and audit logging.

|welcomebigiq|

.. |welcomebigiq| image:: /pictures/welcomebigiq.png
   :scale: 40%

Lab Components
--------------

**Lab Diagram**:

.. image:: ./pictures/diagram_udf.png
   :align: center
   :scale: 40%

**List of instances**:

The following table lists the virtual appliances in the lab along with their credentials to use.

+-------------------------+---------+-----------------------------------------------------+-----------------------------+
| System                  | Version | Description                                         | Credentials                 |
+=========================+=========+=====================================================+=============================+
| BIG-IQ CM               | 7.1.0.1 |                                                     | admin/purple123 *(local)*   |
|                         |         |                                                     | david/david *(RadiusServer)*|
|                         |         |                                                     | paula/paula *(RadiusServer)*|
|                         |         |                                                     | paul/paul *(RadiusServer)*  |
|                         |         |                                                     | larry/larry *(RadiusServer)*|
+-------------------------+---------+-----------------------------------------------------+-----------------------------+
| BIG-IQ DCD              | 7.1.0.1 |                                                     | admin/purple123             |
+-------------------------+---------+-----------------------------------------------------+-----------------------------+
| BIG-IP Boston           | 13.1    | cluster                                             | admin/purple123             |
+-------------------------+---------+-----------------------------------------------------+-----------------------------+
| BIG-IP Seattle          | 14.1    | standalone                                          | admin/purple123             |
+-------------------------+---------+-----------------------------------------------------+-----------------------------+
| BIG-IP Paris            | 14.1    | standalone                                          | admin/purple123             |
+-------------------------+---------+-----------------------------------------------------+-----------------------------+
| BIG-IP San Jose         | 15.1    | Standalone                                          | admin/purple123             |
+-------------------------+---------+-----------------------------------------------------+-----------------------------+
| SSLo Service TAP and L3 |         |                                                     | ubuntu/purple123            |
+-------------------------+---------+-----------------------------------------------------+-----------------------------+
| Venafi Trust Protection | 20.1    |                                                     | venafi/Purple123\@123       |
+-------------------------+---------+-----------------------------------------------------+-----------------------------+
| LAMP Server             |         | - Radius, LDAP, TACAx                               | f5student/purple123         |
|                         |         | - xRDP and noVNC for User Remove Desktop            |                             |
|                         |         | - AWX/Ansible Tower                                 | noVNC password is purple123 |
|                         |         | - GitLab                                            |                             |
|                         |         | - Splunk                                            |                             |
|                         |         | - Application Servers (Hackazon, dvmw, f5 demo app) |                             |
|                         |         | - Traffic Generator (HTTP, Access, DNS, Security)   |                             |
|                         |         | - Visual Studio Code                                |                             |
|                         |         | - Samba                                             |                             |
+-------------------------+---------+-----------------------------------------------------+-----------------------------+

**Networks**:

- 10.1.1.0/24 lab environment Management Network
- 10.1.10.0/24 lab environment External Network
- 10.1.20.0/24 lab environment Internal Network
- 10.1.30.0/24 lab environment SSLo Inline L3 IN Network
- 10.1.40.0/24 lab environment SSLo Inline L3 OUT Network
- 10.1.50.0/24 lab environment SSLo TAP Network
- 172.17.0.0/16 lab environment Docker Internal Network
- 172.100.0.0/16 AWS Internal Network
- 172.200.0.0/16 Azure Internal Network

**LAMP Server  details**:

The Linux box in the environment has multiple cron jobs that are generating traffic that populates the Monitoring tab 
and Application dashboard in BIG-IQ.

Below table shows the list of **Virtual Servers** and *Backend *Web Applications Servers** where various type of traffic
is being sent (check ``crontab`` config for more details).

.. warning:: Make sure the IP address on the external network 10.1.10.0/24 is defined in lab environment on 
             the BIG-IP external interface where you are deploying the application service or VIP.

+---------------------------------------------------------------------------------------------+
| Virtual IP addresses where the traffic generator send traffic to                            |
+================================+============================================================+
| HTTP clean traffic every 5 min | 10.1.10.110-116, 10.1.10.118, 10.1.10.120, 10.1.10.123-142 |
+--------------------------------+------------------------------------------------------------+
| HTTP bad traffic every 3 hours | 10.1.10.110-116, 10.1.10.118, 10.1.10.120, 10.1.10.123-142 |
+--------------------------------+------------------------------------------------------------+
| Access traffic (class 9)       | 10.1.10.117, 10.1.10.119, 10.1.10.121, 10.1.10.222         |
+--------------------------------+------------------------------------------------------------+
| DNS traffic (class 10)         | 10.1.10.203, 10.1.10.204                                   |
+--------------------------------+------------------------------------------------------------+

.. note:: IPs from ``10.1.10.110`` to ``10.1.10.142`` have a corresponding FQDN named from ``site10.example.com`` to ``site42.example.com``.

+-----------------------------------------------------------------------+
| Backend Web Applications Servers                                      |
+=======================================================================+
| 10.1.20.110-123                                                       |
|                                                                       |
| - Port ``80``: hackazon application                                   |
| - Port ``8080``: web-dvwa application                                 |
| - Port ``8081``: f5-hello-world application                           |
| - Port ``8082``: f5-demo-httpd application                            |
| - Port ``8083``: nginx application (delay 300ms loss 30% corrupt 30%) |
| - Port ``446``: ASM Policy Validator                                  |
+-----------------------------------------------------------------------+
