Lab 5.2: Deploy our ``SSG`` in ``Azure``
----------------------------------------

Since we have already seen the different components needed to deploy a ``SSG`` successfully, 
we will automatically deploy it and review its configuration. 

Launch our ``SSG`` - Access our orchestrator - Azure
****************************************************

To setup ``BIG-IQ`` and ``Azure`` automatically, open a ``SSH`` connection on the system called: **Ubuntu Lamp Server**

.. image:: ../pictures/module4/img_module4_lab2_1.png
  :align: center
  :scale: 50%

|

Once connected via ``SSH``, go into the folder: **f5-azure-vpn-ssg**: 

    ``cd f5-azure-vpn-ssg/``

we will need to edit the following files: 

* **config.yml**: This file will contains all the information needed to 
    deploy the ``Azure`` environment successfully. 
* **08a-create-Azure-auto-scaling.yml**: we will change the setup of the default ``SSG`` 
    that gets deployed. we want to deploy 2 instances to review how it is setup as 
    part of a ``SSG`` group. 


Launch our ``SSG`` - Update config.yml - Azure
***********************************************

Use your favorite editor to update this file. 

    ``vi config.yml``

Here are the settings you will need to change to deploy everything successfully: 

* SUBSCRIPTION_ID
* TENANT_ID
* CLIENT_ID
* SERVICE_PRINCIPAL_SECRET
* PREFIX: Specify a ``prefix`` that will be used on each object automatically 
    created. we will use **udf-<your NAME>**. For example: **udf-azure-demo** 

  .. warning:: 
        DO NOT PUT a ``-`` at the end or your deployment will fail. 
        
        We need you to put something so that your PREFIX will be UNIQUE to you or it will overlap with 
        other student's env. If your name is 'common', pick something else that should be unique or append 
        your first name to it. 

        Use udf- in the prefix or your ``SSG`` deployment will fail
        
        Remember that the PREFIX must be 15 CHARACTERS MAX

Save the config file. 

Here is an example of the updated **config.yml** file:

.. code::

    ##################################################################################################
    ###########################         UPDATE VARIABLE BELOW          ###############################
    ##################################################################################################

    # Enabling Azure Marketplace images for programmatic access
    # On the Azure portal go to All Services
    # In the General section, click on Marketplace
    # Type in "F5 BIG-IP" in the Search Box to filter the items
    # Click on each of the images and do the following
    # Click on the "Want to deploy programmatically?"  link on the right
    # Click on "Enable" and Save

    # Select Azure Cloud for VNET and VPN creation: AzureCloud, AzureChinaCloud, AzureUSGovernment, AzureGermanCloud
    Azure_CLOUD: AzureCloud
    # Select Azure Cloud for BIG-IQ SSG: Azure, Azure_CHINA, Azure_US_GOVERNMENT, Azure_GERMANY
    Azure_BIGIQ_CLOUD: Azure

    SUBSCRIPTION_ID: <Subscription Id>
    TENANT_ID: <Tenant Id>
    CLIENT_ID: <Client Id>
    SERVICE_PRINCIPAL_SECRET: <Service Principal Secret>
    # web browser and access token to sign in (if set to yes, delete USERNAME AND PASSWORD variables)
    USE_TOKEN: no

    # A unique searchable prefix to all resources which are created
    # Use a prefix w/o spaces or special characters (NO MORE THAN 10 CHARACTERS, no end with - or special characters)
    PREFIX: udf-azure-demo
    # Also used for the Azure Resource group name

    # Select on of  the region below (default East US) - westus, westeurope, eastasia, brazilsouth ...
    # run az account list-locations --output table
    DEFAULT_LOCATION: eastus

    # Adjust the BIG-IP Version based on your region 
    BYOL_BIGIP_NAME: "f5-big-all-1slot-byol"
    BYOL_BIGIP_VERSION: "13.1.100000" #14.0.001000


.. note:: We don't have to change anything else as long as we use the US-East (N. Virginia) Location

.. warning:: in your **config.yml** file, you have the default password that will be used for the admin user 
    This password will be enforced on all the VEs deployed in your ``SSG``. 

    .. code:: 
        
        # BIG-IQ SSG CONFIG
        BIGIP_USER: admin
        BIGIP_PWD: **************

    MAKE SURE TO NOTE IT SOMEWHERE


Launch our ``SSG`` - Update our SSG configuration - Azure
*********************************************************

To update configuration pushed by the orchestrator, we will update the file called 
**08a-create-azure-auto-scaling.yml**. Use your favorite editor to update it.

Look for this section in the file: 

.. code::

    - include_tasks: ./helpers/post.yml
      with_items:
        - name: Create service scaling group
          url: "{{BIGIQ_URI}}/cm/cloud/service-scaling-groups"
          body: >
            {
                "name": "{{SSG_NAME}}",
                "description": "Azure scaling group",
                "environmentReference": {
                    "link": "https://localhost/mgmt/cm/cloud/environments/{{cloud_environment_result.id}}"
                },
                "minSize": 1,
                "maxSize": 3,
                "maxSupportedApplications": 3,
                "desiredSize": 1,
                "providerType": "Azure",
                "postDeviceCreationUserScriptReference": null,
                "preDeviceDeletionUserScriptReference": null,
                "scalingPolicies": [
                {
                    "name": "scale-out",
                    "cooldown": 30,
                    "direction": "ADD",
                    "type": "ChangeCount",
                    "value": 1
                },
                {
                    "name": "scale-in",
                    "cooldown": 30,
                    "direction": "REMOVE",
                    "type": "ChangeCount",
                    "value": 1
                }]
            }

Change the **minSize** and **desiredSize** from 1 to 2 : 

.. code::

    - include_tasks: ./helpers/post.yml
      with_items:
        - name: Create service scaling group
          url: "{{BIGIQ_URI}}/cm/cloud/service-scaling-groups"
          body: >
            {
                "name": "{{SSG_NAME}}",
                "description": "Azure scaling group",
                "environmentReference": {
                    "link": "https://localhost/mgmt/cm/cloud/environments/{{cloud_environment_result.id}}"
                },
                "minSize": 2,
                "maxSize": 3,
                "maxSupportedApplications": 3,
                "desiredSize": 2,
                "providerType": "Azure",
                "postDeviceCreationUserScriptReference": null,
                "preDeviceDeletionUserScriptReference": null,
                "scalingPolicies": [
                {
                    "name": "scale-out",
                    "cooldown": 30,
                    "direction": "ADD",
                    "type": "ChangeCount",
                    "value": 1
                },
                {
                    "name": "scale-in",
                    "cooldown": 30,
                    "direction": "REMOVE",
                    "type": "ChangeCount",
                    "value": 1
                }]
            }


Launch our ``SSG`` - Trigger the deployment - Azure
***************************************************

Now that the relevant files have been updated, we can trigger the deployment. 

To trigger the deployment, run the following command: 

 ``./000-RUN_ALL.sh ssg``

It will ask you to press Enter to confirm that you subscribed and agreed to 
the EULA in the marketplace. Press enter to start the deployment. 

You should see something like this: 

.. code::

    f5@03a920f8b4c0410d8f:~/f5-azure-vpn-ssg$ nohup ./000-RUN_ALL.sh ssg &
    f5@03a920f8b4c0410d8f:~/f5-azure-vpn-ssg$ tail -f nohup.out

    Did you subscribed and agreed to the software terms for 'F5 BIG-IP Virtual Edition - BEST - BYOL' in Azure Marketplace?

    Enabling Azure Marketplace images for programmatic access:
    - On the Azure portal go to All Services
    - In the General section, click on Marketplace
    - Type in 'F5 BIG-IP Virtual Edition - BEST - BYOL' in the Search Box to filter the items
    - Click on each of the images and do the following
    - Click on the 'Want to deploy programmatically?'  link on the right
    - Click on 'Enable, then Save.'


    EXPECTED TIME: ~45 min

    Installation Azure CLI

    Set Cloud Name to  AzureCloud

    Login
    [
    {
        "cloudName": "AzureCloud",
        "id": "a3615-1ds30-41dfd-a146-dba5dewssdf6a1b",
        "isDefault": true,
        "name": "f5-AZR-SEATTLE",
        "state": "Enabled",
        "tenantId": "abawewsd6-905c-4wwewwws9-9wew8-dfew44rrtwewe33",
        "user": {
        "name": "dbw34343fc-fsdf5-4werswsw4-83wefwdf6-2b9ererdfsdf02b",
        "type": "servicePrincipal"
        }
    }


At this stage, we should start deploying your environment in ``Azure``. 
In your ``Azure Console``, go to **Resource groups**. 

.. image:: ../pictures/module5/img_module5_lab2_1.png
  :align: center
  :scale: 50%

|

Here we can see that the objects are being deployed with the prefix 
**udf-azure-demo** as mentioned in **config.yml** file (prefix attribute)

In the next lab, we will review what has been setup on ``BIG-IQ`` and what was 
deployed in our ``Azure VNET``.


