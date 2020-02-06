Lab 1.1: Simple APM Configuration via BIG-IQ (secure website with basic authentication)
---------------------------------------------------------------------------------------

10.1.10.119 will be use for this lab.

1. First make sure your device has APM module discovered and imported.

2. Check if the Access service is Active.

System > BIOG-IQ DATA COLLECTION > BIG-IQ Data Collection Devices

3. Configure remote logging for the device.

Monitoring > DASHBOARD > Access > Remote Logging configuration
Select both BIG-IPs and click on Configure. Wait until Stats shows Enabled.

4. Create a VIP https in the CONFIGURATION tab and deploy it.

5. Create Access Policy.

5.1 Configuration > ACCESS > Acess Groups, select Boston, then go under ACCESS POLICIES > Per-Session Policies.

Click Create.

General = Advanced

Name: simpleHttpsAccess
Languages: English
Log Settings: /Common/default-log-setting

Save & Close

5.2. Navigate to AUTHENTICATION section, select RADIUS and create a Radius object.

Server: 10.1.1.5
Password: default

5.3. Click on the policy to open the Visual Policy Editor (VPE)

Click on the line between Start and Deny, and add a Logon Page.

Click on the line between Logon Page and Deny, and add a RADIUS Auth.

After the Successful outcome, change Deny to Allow.

5.4. Navigate to VIRTUAL SERVER section, look for the Virtual Server created in step 4 and
associate the access profile with the virtual.

Access Profile: simpleHttpsAccess

5.5. Deploy the Access Policy to the device.

Deployment tab > EVALUATE & DEPLOY > Access

6. Connect as paula/paula from the RDP

7. From BIG-IQ navigate to the Monitoring tab > Access