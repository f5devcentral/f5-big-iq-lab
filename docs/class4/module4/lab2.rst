Lab 4.2: Configure High Availability for BIG-IQ (7.0 and after)
---------------------------------------------------------------
**Overview**

With BIG-IQ v7.0 and above, BIG-IQ CM High Availability can be automated for VMware. Election of the primary BIG-IQ Central Manager goes via a quorum-based technology which enforces consistent fail-over. In case of a fail-over, quorum will make that the secondary BIG-IQ central manager will be able to automatically take over, without an administrator doing the election or promotion from standby to master manually.
As said, full-automated fail-over is only available for VMware. For public cloud providers, like: AWS and Azure, currently only the manual fail-over is supported.

.. note:: If you haven’t setup a **SECOND** BIG-IQ Central Manager, please go to Lab 4.1 and follow the steps.

1. Login to BIG-IQ 1 as user David and go to **System > BIG-IQ HA > BIG-IQ HA Settings**. Check that the current used High Available method is Manual Failover.

.. image:: ../pictures/module4/lab2_1.png
  :align: center
  
 BIG-IQ HA Settings does not have a quorum device configured and this a way to recognize that the used failover is the manual failover.

2. We need to switch the failover method from manual failover to automated failover and therefore we need to break this HA setup. In BIG-IQ HA Settings click **Reset to Standalone**.

3. A pop-up shows up: Reset to Standalone? Click **OK**.

.. image:: ../pictures/module4/lab2_2.png
  :align: center
  
This will take some time (~ 3 minutes) and log you out from BIG-IQ.

4. Once the login window returns for BIG-IQ 1 CM, login as user David and go to System > BIG-IQ HA. Will notice that only one BIG-IQ system is present, and no HA is configured.

5. Click ``Add System`` and fill in the following:

*Properties*
 * IP Address =	10.1.10.13
 * Username = admin
 * Password = purple123
 * Root Password = Purple123
	
*HA Settings*
 * Failover setting = Auto Failover
 * Select: bigiq1dcd.example.com (pull-down)
 * Quorum Root Password = purple123
 * Floating IP	(select) Enable Floating IP (10.1.1.15)

6. Click **Add** and **OK**.

Creating the Automate failover setup with the quorum device takes about 5 minutes.
Once the process is completed the pop-up window will tell you and you can close the window. 

.. image:: ../pictures/module4/lab2_3.png
  :align: center
  
At BIG-IQ HA you will find three devices configured:
 - bigiq1cm.example.com
 - bigiq2cm.example.com
 - bigiq1dcd.example.com

The second BIG-IQ central manager acts as the standby device and the only DCD available in the lab acts as the quorum device. This does not mean it will take CM takes when one fails, but instead it delivers the tiebreak when the active CM fails and failover takes place from active to standby, which than will become the active CM.

7. Click **BIG-IQ HA Settings**.

.. image:: ../pictures/module4/lab2_4.png
  :align: center
  
BIG-IQ HA Settings delivers a bit more detail and also shows us the configured floating IP Address and can be used as the cluster management IP address.

.. image:: ../pictures/module4/lab2_5.png
  :align: center
  
8. To test this, grab a browser on your jumphost and go: https://10.1.1.15 . Which BIG-IQ took the call? 
9. Login with David and go **System > BIG-IQ HA > BIG-IQ HA Settings** and promote the Standby Device. The pop-up will ask: *Promote Standby Device to Active?* Click **OK**.
10.	Repeat step 7.

11.	From the jumphost, open Postman. *(If double-clicking does not work, try right-side of the mouse and press execute or open a terminal and type postman and hit enter.)*
12.	Open the ``BIG-IQ AS3 Lab Postman Collection`` and select **POST BIG-IQ Token (Olivia)**. Before sending, first change the IP address from 10.1.1.4 to 10.1.1.15 and hit **Send**.
13.	Select ``POST BIG-IQ AS3 Declaration`` and change the management IP address to **10.1.1.15**.
14.	Copy below example of an AS3 Declaration and paste as the Body of your declaration.

  POST https://10.1.1.15/mgmt/shared/appsvcs/declare?async=true

.. code-block:: yaml

   {
       "class": "AS3",
       "action": "deploy",
       "persist": true,
       "declaration": {
           "class": "ADC",
           "schemaVersion": "3.7.0",
           "id": "example-declaration-01",
           "label": "Task1",
           "remark": "Task 1 - HTTP Application Service",
           "target": {
               "hostname": "BOS-vBIGIP01.termmarc.com"
           },
           "Task1": {
               "class": "Tenant",
               "MyWebApp1http": {
                   "class": "Application",
                   "template": "http",
                   "statsProfile": {
                       "class": "Analytics_Profile",
                       "collectClientSideStatistics": true,
                       "collectOsAndBrowser": false,
                       "collectMethod": false
                   },
                   "serviceMain": {
                       "class": "Service_HTTP",
                       "virtualAddresses": [
                           "10.1.10.100"
                       ],
                       "pool": "web_pool",
                       "profileAnalytics": {
                           "use": "statsProfile"
                       }
                   },
                   "web_pool": {
                       "class": "Pool",
                       "monitors": [
                           "http"
                       ],
                       "members": [
                           {
                               "servicePort": 80,
                               "serverAddresses": [
                                   "10.1.20.120",
                                   "10.1.20.121"
                               ],
                               "shareNodes": true
                           }
                       ]
                   }
               }
           }
       }
   }

15. Check if it was successful.

- In the response section of Postman
- Login to BOS-vBIG01.termmarc.com by browsing to https://10.1.1.8 (admin/purple123) and check if the partition was created, Task1.
- POST BIG-IQ AS3 Declaration (Delete) to remove the declaration. COpy and paste below declaration and:

POST https://10.1.1.15/mgmt/shared/appsvcs/declare?async=true and Check if the declaration got deleted.

.. code-block:: yaml

  {
    "class": "AS3",
    "action": "deploy",
    "persist": true,
    "declaration": {
        "class": "ADC",
        "schemaVersion": "3.7.0",
        "id": "delete",
        "label": "delete",
        "remark": "delete",
        "target": {
            "hostname": "BOS-vBIGIP01.termmarc.com"
        },
        "apptesting": {
            "class": "Tenant"
        }
    }
  }


Before finishing this lab, there is one task to do. If you are done testing BIG-IQ HA, stop BIG-IQ CM Secondary to avoid additional costs. You might want to switch the active BIG-IQ before stopping the secondary… (or stop BIG-IQ primary in UDF or Ravello and skip the next steps)

16.	Go to BIG-IQ CM Secondary https://10.1.1.13 and then: **Systems > BIG-IQ HA > BIG-IQ HA Settings**.
17.	Promote the standby device bigiq1cm.example.com, at the pop-up click **OK**.
18.	Refresh the Browser window and wait (takes ~5min) until the BIG-IQ failover IP gets redirected to BIG-IQ CM (10.1.1.4) and check if it has become the primary unit.
19.	Stop BIG-IQ CM Secondary in either UDF or Ravello.

