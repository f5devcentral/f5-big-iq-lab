Lab 4.2: Create Application using Service Catalog Template
----------------------------------------------------------
.. warning:: Starting BIG-IQ 6.1, AS3 should be the preferred method to deploy application services through BIG-IQ.

Connect as **paula** to create a new application. Click on the *Create* button
and select the template previously created ``f5-HTTP-lb-custom-template``.

Follow the same steps as described in *Lab 2.3: Create Application* (use the default values set in the template for the virtual servers and nodes).

Type in a Name for the application you are creating.

- Application Name: ``site16.example.com``

To help identify this application when you want to use it later, in the Description field, type in a brief description for the application you are creating.

- Description: ``My Second Application on F5 Cloud Edition``

For Device, select the name of the device you want to deploy this application to. (if the HTTP statistics are not enabled, they can be enabled later on after the application is deployed)

- BIG-IP: Select ``BOS-vBIGIP01.termmarc.com`` and check ``Collect HTTP Statistics``
