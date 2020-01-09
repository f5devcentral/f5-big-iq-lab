Lab 1.1: Proactive Bot Defense Configuration and Monitoring
-----------------------------------------------------------
Protects apps from automated attacks by bots and other malicious tools.

The goal of this lab is to show how to use BIG-IQ to configure the BOT protection to an HTTP Application Service 
and how to use BIG-IQ BOT Dashboards to monitors the BOT traffic.

.. note:: This lab requires BIG-IP 14.1 and BIG-IQ 7.0 minimum. AVR also needs to be provisioned on the device. See more details `K12121934`_.

.. _`K12121934`: https://support.f5.com/csp/article/K12121934

Official documentation about BOT Monitoring on BIG-IQ can be found on the `BIG-IQ Knowledge Center`_.

.. _`BIG-IQ Knowledge Center`: https://techdocs.f5.com/en-us/bigiq-7-0-0/mitigating-managing-bot-defense-using-big-iq/monitoring-bot-defense-activity.html

Connect as **david** on BIG-IQ.

1. Create the DCD Pool and Log Destinations. Navigate to Configuration Tab > LOCAL TRAFFIC > Pools, click Create.

- Name: bot-remote-dcd-asm-pool
- Health Monitors: tcp
- Pool Member/Port: 10.1.10.6:8514

.. image:: ../pictures/module1/img_module1_lab1_1.png
  :align: center
  :scale: 60%

|

Navigate to Configuration Tab > LOCAL TRAFFIC > Logs > Log Destinations, click Create.

- Name Log Destination hslog: bot-remote-logging-destination-remote-hslog-8514
- Device: SEA-vBIGIP01.termmarc.com
- Pool: bot-remote-dcd-asm-pool previously created

.. image:: ../pictures/module1/img_module1_lab1_2.png
  :align: center
  :scale: 60%

|

Navigate to Configuration Tab > LOCAL TRAFFIC > Logs > Log Destinations, click Create.

- Name Log Destination Splunk: bot-remote-logging-destination-splunk-8514
- Type: Splunk
- Forward To: Remote High Speed Log - bot-remote-logging-destination-remote-hslog-8514 previously created

.. image:: ../pictures/module1/img_module1_lab1_3.png
  :align: center
  :scale: 50%

|

.. note:: This is to add the formating supported by BIG-IQ

2. Create the Log Publisher. Navigate to Configuration Tab > LOCAL TRAFFIC > Logs > Log Publisher. click Create.

- Name: bot-remote-logging-publisher-8514
- Log Destinations: bot-remote-logging-destination-splunk-8514  previously created

.. image:: ../pictures/module1/img_module1_lab1_4.png
  :align: center
  :scale: 50%

|

3. Pin the new Log Publisher to the SEA-vBIGIP01.termmarc.com device. Navigate to Pinning Policies and add the Log Publisher previously created to SEA-vBIGIP01.termmarc.com.

.. image:: ../pictures/module1/img_module1_lab1_5.png
  :align: center
  :scale: 50%

|

4. Deploy the Pool, Log Destinations and Log Publisher. Go to Deployment tab > EVALUATE & DEPLOY > Local Traffic & Network.

Create a Deploments to deploy the Remote Logging Changes on the SEA BIG-IP.

.. image:: ../pictures/module1/img_module1_lab1_6.png
  :align: center
  :scale: 50%

|

Make sure the deployment is successfull.

Connect as **admin** on BIG-IP SEA-vBIGIP01.termmarc.com.

6. Create the Bot Defense Profile. Navigate to Security > Bot Defense. Click Create.

.. warning:: This step can be done from BIG-IQ UI starting BIG-IQ 7.1 version.

.. image:: ../pictures/module1/img_module1_lab1_7.png
  :align: center
  :scale: 50%

|

- Name: lab-bot-defense-profile
- Enforcement Mode: Blocking
- Enforcement Readiness Period: 0 (**lab only**)

.. image:: ../pictures/module1/img_module1_lab1_8.png
  :align: center
  :scale: 50%

|

- Untrusted Bot: Block

.. image:: ../pictures/module1/img_module1_lab1_9.png
  :align: center
  :scale: 50%

|

6. Create a new BOT Logging profile. Navigate to Security > Event Logs > Logging Profiles. Click Create.

.. warning:: This step can be done from BIG-IQ UI starting BIG-IQ 7.1 version.

.. image:: ../pictures/module1/img_module1_lab1_10.png
  :align: center
  :scale: 50%

|

- Name: lab-bot-logging-profile
- Properties: select Bot Defense
- Remote Publisher: select previously Remote Publisher previously created.
- Logs Requests: select all options (Human Users, Bots, etc...)]

.. image:: ../pictures/module1/img_module1_lab1_11.png
  :align: center
  :scale: 50%

|


7. Create an HTTP Virtual Server with the following parameters:

.. warning:: This step could be done from BIG-IQ but in order to avoid going back and forth between BIG-IP and BIG-IQ,
             we are creating the HTTP Application Service from BIG-IP.

- Name: vs_bot_defense_lab
- Destination Address: 10.1.10.124
- Default HTTP profile
- Source Address Translation: auto map
- Pool: select an exiting pool (e.g. /Common/site42.example.com/pool_0)

Edit the VIP and go to Security tab. Assign the Bot Defense Profile and the Log Profile previously created.

.. image:: ../pictures/module1/img_module1_lab1_12.png
  :align: center
  :scale: 50%

|

Connect as **david** on BIG-IQ.

8. Navigate to Device tab and re-discover/re-import SEA-vBIGIP01.termmarc.com.

.. image:: ../pictures/module1/img_module1_lab1_13.png
  :align: center
  :scale: 50%

|

.. image:: ../pictures/module1/img_module1_lab1_14.png
  :align: center
  :scale: 50%

|

9. On Lamp server, generate HTTP traffic from a browser and CLI.

Connect via ``SSH`` to the system *Ubuntu Lamp Server* and run:

``while true; do curl http\:\/\/10.1.10.124; sleep 1; done``

From UDF, launch a Console/RDP session to have access to the Ubuntu Desktop. 
To do this, in your UDF deployment, click on the *Access* button
of the *Ubuntu Lamp Server* system and select *Console* or *XRDP*.

.. note:: Modern laptops with higher resolutions you might want to use 1440x900 and once XRDP is launched Zoom to 200%)

.. image:: ../../pictures/udf_ubuntu.png
    :align: left
    :scale: 70%

|

Open Chrome and Navigate to the URL http\:\/\/10.1.10.124.

.. image:: ../pictures/module1/img_module1_lab1_15.png
  :align: center
  :scale: 50%

|

Notice the HTTP requests are going through when using a real browser but are blocked when using curl.

10. Now, have a look at the BIG-IQ BOT Dashboard available on BIG-IQ under Monitoring > DASHBOARDS > Bot Traffic.

.. image:: ../pictures/module1/img_module1_lab1_16.png
  :align: center
  :scale: 50%

|

.. image:: ../pictures/module1/img_module1_lab1_17.png
  :align: center
  :scale: 50%

|

You can also see the details of each request logged nunder Monitoring > EVENTS > Bot > Bot Requests.

.. image:: ../pictures/module1/img_module1_lab1_18.png
  :align: center
  :scale: 50%

|