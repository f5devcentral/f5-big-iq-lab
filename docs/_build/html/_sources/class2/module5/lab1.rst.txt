Lab 5.1: Prepare your ``Azure`` deployment 
-----------------------------------------

.. warning:: The SSG will be automatically delete 23h after the deployment was started.

In module1/Lab 1.1, we saw the different components to setup a SSG: 

* ``License Pool`` 
* ``IP Pools``
* ``Device Template``
* ``Cloud Provider``
* ``Cloud Environment``

When you want to deploy a ``SSG`` in ``Azure``, you don't need to provide the same amount of information:

* A ``License Pool`` is not mandatory. We are free to use ``Utility Billing`` (pay-per-use) in ``AZURE``
* ``IP Pools`` are not needed. When we deploy a ``SSG`` in ``AZURE``, the deployed ``Virtual Edition(s)`` 
  will be using our single NIC deployment. It means that we use one interface for management and traffic 
  processing. In this case, the IP Address assigned to the device will be picked automatically by ``AZURE``


To deploy our ``SSG`` in ``Azure``, we will need to do a few things: 

* Setup an ``Service Principal Account`` that will allow us to setup our ``SSG`` via 
  the ``Azure`` API

Once this is done, we will be able to deploy our ``SSG``. We will rely on some ansible scripts to: 

* Create a VNET, subnets, ...
* Deploy an APP in ``Azure``
* Setup an ``Azure VPN`` connection between our ``UDF`` environment and this newly deployed ``Azure VNET``

.. note:: in this lab, we consider that you have access to ``Azure``. We won't cover this topic. 

Setting up a Service Principal Account
**************************************

.. note:: Needs to be done by an admin in the subscription

1. Registering an application

  - On the Azure portal, go to Azure Active Directory → App registrations
  - Click on "+ New registration"
  - Enter the following values
    Name: <Name of the application>
  - Click Create

.. image:: ../pictures/module5/img_module5_lab1_1a.png
  :align: center
  :scale: 50%

|

  - Click on Certificates & secrets → New client secret
  - Enter a Description and select Expiration period.

.. image:: ../pictures/module5/img_module5_lab1_1b.png
  :align: center
  :scale: 50%

|

2. Adding additional Application Owners

  - On the Azure portal, go to Azure Active Directory → App registrations → <the app you created in Registering an application>
  - Click on Settings → Owners → Add owner
  - Enter the user's F5 email address to search
  - Select the user and Click on Select

.. image:: ../pictures/module5/img_module5_lab1_2.png
  :align: center
  :scale: 50%

|

3. Generating Service Principal Secret

  - On the Azure portal, go to Azure Active Directory → App registrations → <the app you created in Registering an application>
  - Click on Settings → Keys
  - Enter the user's name in the Description field and select "Never Expires" for the duration
  - Click on Save
  - Copy the Value field and save it somewhere. This will need to be provided to the user to be able to configure an Azure provider in BIG-IQ

.. image:: ../pictures/module5/img_module5_lab1_3.png
  :align: center
  :scale: 50%

|

4. Granting access control to the application

- On the Azure portal, go to Azure Active Directory → All Services
- Click on Subscriptions
- Click on the subscription that you are using for the application
- Click on Access Control (IAM) 
- Click on Add
- Select Role Assignment
- Select "Contributor" in the drop down for the Role
- Type in the Application name created in Step 1.
- Click on Save

.. image:: ../pictures/module5/img_module5_lab1_4.png
  :align: center
  :scale: 50%

|

5. Credentials needed for configuring Azure Provider in BIG-IQ

The following pieces of information is needed to configure an Azure Provider.
This information is required to make API calls to Azure for resource CRUD operations, either through Java or through Ansible.

- **Subscription Id**: You can get this by clicking on Subscriptions in Azure portal and copying the Subscription Id for the f5-AZR_7801_PTG_MANOVA-Dev subscription
- **Tenant Id**: Go to Azure Active Directory → Properties and copy the value of the Directory ID. This is the tenant Id.
- **Client Id**: Go to Azure Active Directory → App registrations and copy the value of the Application ID. This is the client ID.
- **Service Principal Secret**: Copy the value saved in step 5 of Generating Service Principal Secret

.. warning:: we need something unique for the User name since other student will do the lab and you may use 
  same Azure corporate account. 


Subscribe to the BIG-IP instance in the ``Azure MArketplace``
*************************************************************

Before being able to deploy an instance in ``Azure``, you'll have to **subscribe** to this license agreement

Go here to **subscribe** to the right F5 instance we will use in this lab: 

`F5 BIG-IP VE – ALL (BYOL, 1 Boot Location) <https://portal.azure.com/#blade/Microsoft_Azure_Marketplace/GalleryFeaturedMenuItemBlade/selectedMenuItemId/home/searchQuery/f5-bigip/resetMenuId/>`_

Once you've subscribed, you should see something like this: 

.. image:: ../pictures/module5/img_module5_lab1_5.png
  :align: center
  :scale: 50%

|

.. image:: ../pictures/module5/img_module5_lab1_6.png
  :align: center
  :scale: 50%

|