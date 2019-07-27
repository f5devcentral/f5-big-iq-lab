Lab 5.6: Troubleshooting (Azure)
--------------------------------

Here are some Troubleshooting steps to help you troubleshooting issue with your Azure SSG deployment and Application:

1. In the BIG-IQ UI, if the application deployment failed, click **Retry**.
2. In the BIG-IQ UI, check the BIG-IQ license on Console Node and Data Collection Device (**System** > **THIS DEVICE** > **Licensing**) and the BIG-IP license pool (**Devices** > **LICENSE MANAGEMENT** > **Licenses**).
3. In the BIG-IQ UI, check the Cloud Environment to ensure all of the information is populated correctly (**Applications** > **ENVIRONMENTS** > **Cloud Environments**).
4. In the BIG-IQ CLI, check following logs: /var/log/setup.log, /var/log/restjavad.0.log and /var/log/orchestrator.log.
5. In Azure Active Directory, ensure that app registration has the necessary permissions for API access, to delegate permissions to other users, and to add the users to the owner list of app registration.
6. Ensure you assigned the contributor role (RBAC) to the scope of the current resource/subscription associated with the app registration.
7. If you encountere a **MarketPurchaseEligibility** error while deploying the template, check the availability of BIG-IP and BIG-IQ. 
   
   For example, for BIG-IP:

   ``Get-AzureRmMarketplaceTerms -Publisher "f5-networks" -Product "f5-big-ip-byol" -Name "f5-big-all-1slot-byol" | Set-AzureRmMarketplaceTerms -Accept``

8. If the cloud provider test connection fails, ensure the service prinicpal associated with application has all requried permissions. If the cloud provider connection is still unsuccessful, restart the instances and check again.

9. If you encouter the following error:

    ``Error {u'message': u"The subscription is not registered for the resource type 'components' in the location 'westus'. Please re-register for this provider in order to have access to this location.", u'code': u'MissingRegistrationForLocation'}``
    
   This is caused by recent changes in Azure Application Insight GA in some regions. Try to deploy the quickstart in different location.
    
.. warning:: This template is not supported in the regions where `Microsoft insights`_ is not available (example of supported region: East US, Southeast Asia, Canada Central, West Europe, Central India, UK South, more to come in Q1 2019)

.. _Microsoft insights: https://azure.microsoft.com/en-us/global-infrastructure/services/?regions=all&products=monitor

10. In Azure Marketplace, check if you have subscribed and accepted the terms for the F5 products.

.. image:: ../pictures/module5/img_module5_lab1_5.png
  :align: center
  :scale: 50%

11. In Azure Console, confirm the Access Key has the necessary permissions (review lab 1).