Lab 1.2: Configuring L7 Behavioral DoS Protection (new 7.1)
-----------------------------------------------------------

Workflow
^^^^^^^^

1. **David** creates the Log Destinations and Publisher either using the UI or the API/AS3
2. **Larry** creates the L7 DoS & Logging Profiles
3. **David** creates the AS3 template and reference L7 Behavioral DoS & Logging profile created by **Larry**
4. **David** creates the application service using the template created previously
5. **Larry** review the BIG-IQ L7 DoS dashboards

Prerequisites
^^^^^^^^^^^^^

1. Navigate to the Device tab and complete Discovery & Import on **SJC-vBIGIP01.termmarc.com**. 
   Choose *Create Version* for default LTM profiles and *Set all BIG-IP* for other objects.

2. Once LTM module import is completed, Discover & Import **Shared Security (SSM)** and **Web Application Security (ASM)** modules.
   Choose *Set all BIG-IP* when conflict resolution open.

3. Check if the **DoS Protection** service is Active  
   under System > BIG-IQ DATA COLLECTION > BIG-IQ Data Collection Devices.


DoS Log Destinations and Publisher creation using UI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. warning:: If you want to use API to create those objects, skip this part and go to the next one.

1. Create the DCD Pool and Log Destination. Navigate to Configuration Tab > LOCAL TRAFFIC > Pools, click Create.

- Name: ``dos-remote-dcd-pool``
- Health Monitors: ``tcp``
- Pool Member/Port: ``10.1.10.6:8520``

2. Navigate to Configuration Tab > LOCAL TRAFFIC > Logs > Log Destinations, click Create.

- Name Log Destination hslog: ``dos-remote-logging-destination-remote-hslog-8520``
- Device: ``SJC-vBIGIP01.termmarc.com``
- Pool: ``dos-remote-dcd-pool`` previously created

3. Navigate to Configuration Tab > LOCAL TRAFFIC > Logs > Log Destinations, click Create.

- Name Log Destination Splunk: ``dos-remote-logging-destination-splunk-8520``
- Type: ``Splunk``
- Forward To: ``Remote High Speed Log`` - ``dos-remote-logging-destination-remote-hslog-8520`` previously created

.. note:: This is to add the formatting supported by BIG-IQ

4. Create the Log Publisher. Navigate to Configuration Tab > LOCAL TRAFFIC > Logs > Log Publisher. click Create.

- Name: ``dos-remote-logging-publisher-8520``
- Log Destinations: ``dos-remote-logging-destination-splunk-8520`` previously created

5. Pin the new Log Publisher to the SJC-vBIGIP01.termmarc.com device. Navigate to Pinning Policies and 
   add the Log Publisher previously created to SJC-vBIGIP01.termmarc.com.

6. Deploy the Pool, Log Destinations, Log Publisher. Go to Deployment tab > EVALUATE & DEPLOY > Local Traffic & Network.

Create a Deployment to deploy the Remote Logging Changes on the SJC BIG-IP.

Make sure the deployment is successful.

DoS Log Destinations and Publisher creation using API/AS3
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. From the lab environment, launch a xRDP/noVNC session to have access to the Ubuntu Desktop. 
To do this, in your lab environment, click on the *Access* button of the *Ubuntu Lamp Server* 
system and select *noVNC* or *xRDP*.

.. note:: Modern laptops with higher resolutions you might want to use 1440x900 and once XRDP is launched Zoom to 200%.

.. image:: ../../pictures/udf_ubuntu.png
    :align: left
    :scale: 40%

|

You can also directly using Postman on your laptop and use the following URL (Go to **BIGIQ CM (Config Mgt)** > **Access Methods** > **API**):

.. image:: ../../pictures/udf_bigiq_api.png
    :align: center
    :scale: 40%

|

Open Chrome and Postman.

For Postman, click right and click on execute (wait ~2 minutes).

.. note:: If Postman does not open, open a terminal, type ``postman`` to open postman.

.. image:: ../../pictures/postman.png
    :align: center
    :scale: 40%

|

Using the declarative AS3 API, let's send the following BIG-IP configuration through BIG-IQ:

Using Postman select ``BIG-IQ Token (david)`` available in the Collections.
Press Send. This, will save the token value as _f5_token. If your token expires, 
obtain a new token by re-sending the ``BIG-IQ Token``

.. note:: The token timeout is set to 5 min. If you get the 401 authorization error, request a new token.

2. Copy below AS3 declaration into the body of the **BIG-IQ AS3 Declaration** collection in order to create 
   the service on the BIG-IP through BIG-IQ:

  POST https\:\/\/10.1.1.4/mgmt/shared/appsvcs/declare?async=true

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 9,20,22

      {
          "class": "AS3",
          "action": "deploy",
          "persist": true,
          "declaration": {
              "class": "ADC",
              "schemaVersion": "3.12.0",
              "target": {
                  "address": "10.1.1.11"
              },
              "dos": {
                  "class": "Tenant",
                  "security-log-profile": {
                      "class": "Application",
                      "template": "generic",
                      "dos-remote-dcd-pool": {
                          "class": "Pool",
                          "members": [
                              {
                                  "servicePort": 8520,
                                  "serverAddresses": [
                                      "10.1.10.6"
                                  ],
                                  "shareNodes": true
                              }
                          ]
                      },
                      "dos-remote-logging-destination-remote-hslog-8520": {
                          "class": "Log_Destination",
                          "type": "remote-high-speed-log",
                          "pool": {
                              "use": "dos-remote-dcd-pool"
                          }
                      },
                      "dos-remote-logging-destination-splunk-8520": {
                          "class": "Log_Destination",
                          "type": "splunk",
                          "forwardTo": {
                              "use": "dos-remote-logging-destination-remote-hslog-8520"
                          }
                      },
                      "dos-remote-logging-publisher-8520": {
                          "class": "Log_Publisher",
                          "destinations": [
                              {
                                  "use": "dos-remote-logging-destination-splunk-8520"
                              }
                          ]
                      }
                  }
              }
          }
      }

3. Navigate to Device tab and re-discover/re-import SJC-vBIGIP01.termmarc.com.

.. image:: ../pictures/module1/img_module1_lab1_7.png
  :align: center
  :scale: 40%

|

.. image:: ../pictures/module1/img_module1_lab1_8.png
  :align: center
  :scale: 40%

|


DoS Logging Profile creation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Create a new DoS Logging profile. Navigate to Security > Event Logs > Logging Profiles. Click Create.

- Name: ``lab-dos-logging-profile``
- Properties: select ``Dos Protection``
- Remote Publisher: ``dos-remote-logging-publisher-8520``

2. Pin the new DoS Logging profile to the SJC-vBIGIP01.termmarc.com device.
   Navigate to Pinning Policies and add it to SJC-vBIGIP01.termmarc.com.


L7 BaDOS Profile creation
^^^^^^^^^^^^^^^^^^^^^^^^^

1. Go to Configuration > SECURITY > Shared Security > DoS Protection > DoS Profiles, click Create, configure Behavioral & Stress-based Detection
   and fill in the settings:

- Name: ``lab-bados-profile``
- Operation Mode: ``Blocking``
- Thresholds Mode: ``Automatic``
- Mitigation: ``Standard protection``
- Enable Signature Detection
- Enabling Bad Actor Detection

2. Pin the new DoS Profile to the SJC-vBIGIP01.termmarc.com device.
   Navigate to Pinning Policies and add the Log Publisher previously created to SJC-vBIGIP01.termmarc.com.


3. Deploy the BOT Defense profile. 
   Go to Deployment tab > EVALUATE & DEPLOY > Shared Security.

Create a Deployment to deploy the Remote Logging Changes on the SJC BIG-IP.

Make sure the deployment is successful.


AS3 BOT Template creation and application service deployment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Navigate to the Applications tab > APPLICATION TEMPLATES.

Select the ``AS3-F5-HTTP-lb-template-big-iq-default-<version>`` AS3 Template and clone it.

Rename it ``LAB-HTTP-BaDOS``. 

.. image:: ../pictures/module1/img_module1_lab1_16.png
  :align: center
  :scale: 40%

|

Edit the new cloned template and select the Service_HTTP class.

- Look for the attribute called ``profileDOS`` and set it to ``/Common/lab-bados-profile``.

- Look for the attribute called ``Security Log Profiles`` and set it to ``/Common/lab-dos-logging-profile``.

At the top right corner, click on **Publish and Close**

2. Navigate to the APPLICATION menu, click on **Create** 

Assign the Bot Defense Profile and the Log Profile previously created.

+---------------------------------------------------------------------------------------------------+
| Application properties:                                                                           |
+---------------------------------------------------------------------------------------------------+
| * Grouping = New Application                                                                      |
| * Application Name = ``LAB_BaDOS``                                                                |
| * Description = ``BaDOS``                                                                         |
+---------------------------------------------------------------------------------------------------+
| Select an Application Service Template:                                                           |
+---------------------------------------------------------------------------------------------------+
| * Template Type = Select ``LAB-HTTP-BaDOS [AS3]``                                                 |
+---------------------------------------------------------------------------------------------------+
| General Properties:                                                                               |
+---------------------------------------------------------------------------------------------------+
| * Application Service Name = ``BaDOS_service``                                                    |
| * Target = ``SJC-vBIGIP01.termmarc.com``                                                          |
| * Tenant = ``tenant5``                                                                            |
+---------------------------------------------------------------------------------------------------+
| Pool                                                                                              |
+---------------------------------------------------------------------------------------------------+
| * Members: ``10.1.20.123``                                                                        |
+---------------------------------------------------------------------------------------------------+
| HTTP_Profile. Keep default.                                                                       |
+---------------------------------------------------------------------------------------------------+
| Service_HTTP                                                                                      |
+---------------------------------------------------------------------------------------------------+
| * Virtual addresses: ``10.1.10.138``                                                              |
| * profileDOS: ``/Common/lab-bados-profile``                                                       |
| * securityLogProfiles: ``/Common/lab-dos-logging-profile``                                        |
+---------------------------------------------------------------------------------------------------+
| Analytics_Profile. Keep default.                                                                  |
+---------------------------------------------------------------------------------------------------+

.. note:: You are attaching the DoS and logging profiles to the VIP using AS3.

The application service called ``tenant5_BaDOS_service`` is now created on the BIG-IQ dashboard
under the application called ``LAB_BaDOS``.


Both legitimate and attack traffic will have XFF header inserted by the BIG-IP to simulate geografically 
distributed clients by XFF_mixed_Attacker_Good iRule:

.. code-block:: yaml

        when HTTP_REQUEST {
            # Good traffic
            if { [IP::addr [IP::client_addr] equals 10.1.10.100] } {
                set xff [expr int(rand()*250)].[expr int(rand()*250)].[expr int(rand()*250)].[expr int(rand()*250)]
                HTTP::header insert X-Forwarded-For $xff
            }
            # Attack traffic (AB)
            if { [IP::addr [IP::client_addr] equals 10.1.10.200] } {
                set xff 201.173.99.[expr int(rand()*250)]
                HTTP::header insert X-Forwarded-For $xff
            }
        }  


Traffic simulation and Dashboard/Events
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Generate baseline legitimate traffic. On Lamp server, generate HTTP traffic from a browser and CLI.

Connect via ``SSH`` to the system *Ubuntu Lamp Server* and run:

``/home/f5student/scripts/behavioral-DoS/baseline_menu.sh``

Choose ``1) increasing``.

2. Open a different SSH session on the lamp server and run:

``/home/f5student/scripts/behavioral-DoS/baseline_menu.sh``

Choose ``2) alternate``.

3. Wait for the machine learning algorithm to learn traffic behavior for at least 15min.

4. Start the attack traffic, open a different SSH session on the lamp server and run:

``/home/f5student/scripts/behavioral-DoS/AB_DOS.sh``

Choose ``1) Attack start - similarity``.

5. Now, have a look at the BIG-IQ DoS Dashboard available on BIG-IQ under **Monitoring > DASHBOARDS > DDoS > Protection Summary**.

6. Go look also at the **HTTP Analysis** and **Attack History**.

7. Stop previous attack and start a different one.

``/home/f5student/scripts/behavioral-DoS/AB_DOS.sh``

Choose ``2) Attack start - score``.

