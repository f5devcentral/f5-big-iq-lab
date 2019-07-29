Lab 6.3: Application modification
---------------------------------
Task3b – Application modification
---------------------------------
Through the GUI and when allowed, the application owner is able to make small modifications.

22.	In Task3_http_service, select Servers and Configuration and add a Pool Member.
    a.	Click the + next to Server Addresses and add: 10.1.20.131.
    b.	Click ‘Save & Close’
<picture> 
23.	Check BOS-vBIGIP01.termmarc.com (partition Task3) Local Traffic > Pools and find ‘Pool’. (it will have Task3/http_service as the partition/path or use search. Select Pool and go to members.
24.	Now back to the BIG-IQ and Task_http_service application and select Application Service > Configuration and scroll down in the AS3 declaration and find that the schema has added the second pool member.
<picture> 
Through the API you can’t modify the application service once deployed. With AS3 via the GUI you can. Remember, that through the API you would do a redeploy to add additional services. From the flipside, the GUI only allows you to modify what has been permitted (made editable) when the template was created. 

