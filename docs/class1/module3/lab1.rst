Lab 3.1: Importing AS3 templates
--------------------------------

.. note:: Estimated time to complete: **5 minutes**

.. include:: /accesslab.rst

View AS3 templates section
^^^^^^^^^^^^^^^^^^^^^^^^^^
1. Login to BIG-IQ as **david** .

2. Go to **Applications > Application Templates** and review the top section which is titled **AS3 Templates**.

Notice there are two different types of Templates (AS3 Templates and Service Catalog Templates). 
**AS3 Templates are the recommended templates** for deploying new application services. 
Service Catalog Templates while still supported, are not recommended for new environments.

In this lab you will utilize the AS3 templates. Note the **Import Templates** hyperlink in the top right hand corner of the page. 
This link will take you to the **f5devcentral/f5-big-iq** repository on Github, where F5 publishes BIG-IQ AS3 templates and instructions
on how to import them into BIG-IQ.

A new BIG-IQ v7.0 deployment will NOT include AS3 templates out of the box.
If you want to start using AS3 templates which are provided by F5, then those AS3 templates can be found 
through the following link: https://github.com/f5devcentral/f5-big-iq

Import AS3 BIG-IQ templates
^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Navigate under **Applications > Application Templates**, click **Import Templates** at the right top corner.

.. image:: ../pictures/module3/lab-1-2.png
  :scale: 60%
  :align: center

2. Make yourself familiar with the Github page and understand which AS3 templates are available.

3. In this lab, the AS3 templates are already imported in BIG-IQ.

4. Walk through the provided templates and select them to understand the structure.
   If you are not already familiar with AS3, visit the `Application Services 3 Extension Documentation`_ and `Managing BIG-IQ AS3 Templates`_ Documentation.
   
   You can also look at the `Module 2`_ in this lab guide which will give you more information on how AS3 was integrated with BIG-IQ.

.. _Module 2: ../module2/module2.html
.. _Application Services 3 Extension Documentation: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/#introduction
.. _`Managing BIG-IQ AS3 Templates`: https://techdocs.f5.com/en-us/bigiq-7-0-0/monitoring-managing-applications-using-big-iq.html