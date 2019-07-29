Lab 6.2: Application Creation using AS3 through BIG-IQ GUI
----------------------------------------------------------

HTTP Service using AS3 through GUI
----------------------------------

#.	Log in as Paula in BIG-IQ.

#.	Select Create Application to Create an Application Service

		Application properties
		Grouping: New Application
		Application Name: as3guiapp.example.com
		Select an Application Service Template
     	Template Type: Select => AS3-F5-HTTP-lb-template-big-iq-default-v9 [AS3] (Are you able to find it?)
  
	It is expected that the mentioned template is not in the list. If we want Paula to deploy this ‘AS3-F5-HTTP-lb-template-big-iq-default-v9 [AS3]’ template, we first need to have those templates assigned to hear via an administrator. 

#.	Logout as Paula and login to BIG-IQ as David. (if asked: Leave site? Select: Leave)

#.	Select Applications > Application Templates and notice the ‘Published’ templates. The template Paula wants to use is not listed as a ‘Published’ template.

#.	Select AS3-F5-HTTP-lb-template-big-iq-default-<version> and click Published.

	<picture>

#.	Go to System > Role Management > Roles and select Application Roles at the Custom Roles section (not at Application Roles). Here you will see the collection of the Custom Application Roles. 

#.	Scroll down to AS3 Templates. As you can see, Paula does not have permission the create applications based on AS3 Templates. Let’s change this:

      a.	Select all AS3 Templates and click the arrow to get all templates in the ‘Selected’ section
      b.	Select Save & Close.

#.	Logout as David and log back in as Paula and click Create application.

#.	Select Create Application to Create an Application Service:

		Application properties
		Grouping: New Application
		Application Name: as3guiapp.example.com
		Description: My first AS3 template deployment through a GUI

		Select an Application Service Template

			Template Type: AS3-F5-HTTP-lb-template-big-iq-default-<version> [AS3]
			General Properties
			Application Service Name: http_service
			Target: BOS-vBIGIP01.termmarc.com
			Tenant: Task3

			Leave the Analytics_Profile at its default but check out the options you have.
	
			Leave HTTP_Profile at its default
			
			Pool
			Members: 10.1.20.130 <just picked at random, you want to change this>  
	
			Service_HTTP
			Virtual addresses: 10.1.10.130 <just picked at random, you want to change this>  
		
			Go to View Sample API Request in the right upper corner and select it. You will have a full AS3 declaration 			schema, scroll through it and hit close when done.
	
			<picture>
	
    	Click Create.
  
#.	Logon to SEA-vBIGIP01.termmarc.com and verify the Application is correctly deployed in partition Task3.

#.	Logon to BIG-IQ as Paula and check out the Application tab. 

    a.	(if not visible, click refresh in the upper right corner)

#.	Testing the application. Open a browser in the jumphost and type the VS IP address.

#.	Select as3guiapp.example.com. You will notice as3guiapp.example.com acts as grouping application or global application where underneath multiple services can be gathered.  The next window will show you that a new application has been created, named: Task3_http_service.

<picture>

#.	Select Task3_http_service and select Application Service and Configuration. Here you can find the deployed AS3 declaration.

<picture>

Notice, though you deployed a config through the GUI via template, since this template was based upon AS3 it will show the according structure of a JSON schema.
