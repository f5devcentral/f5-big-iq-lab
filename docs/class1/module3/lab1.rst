Lab 3.1: Importing AS3 templates
--------------------------------

Official documentation about AS3 application service management via a GUI can be found on the `BIG-IQ Knowledge Center`_.

.. _`BIG-IQ Knowledge Center`: https://techdocs.f5.com/en-us/bigiq-7-0-0/monitoring-managing-applications-using-big-iq.html

From the lab environment, launch a remote desktop session to have access to the Ubuntu Desktop. 
To do this, in your lab environment, click on the *Access* button
of the *Ubuntu Lamp Server* system and select *noVNC* or *xRDP*.

.. note:: Modern laptops with higher resolutions you might want to use 1440x900 and once XRDP is launched Zoom to 200%.

.. image:: ../../pictures/udf_ubuntu.png
    :align: left
    :scale: 60%

|


View AS3 templates section
^^^^^^^^^^^^^^^^^^^^^^^^^^
1. Login to BIG-IQ as **david** by opening a browser and go to: ``https://10.1.1.4``

2. Go to Applications > Application Templates and review the top section which is titled **AS3 Templates**.

Notice there are two different types of Templates (AS3 Templates and Service Catalog Templates). 
AS3 Templates are the recommended templates for deploying new application services. 
Service Catalog Templates while still supported, are not recommended for new environments.

In this lab you will utilize some of the new templates that have the TCP analytics profiles built in. Note the
**Import Templates** hyperlink in the top right hand corener of the page. 
This link will take you to the **f5devcentral/f5-big-iq** repository on Github, where F5 will push new templates.  

A new BIG-IQ v7.0 deployment will NOT include AS3 templates out of the box.
If you want to start using AS3 templates which are provided by F5, then those AS3 templates can be found 
through the following link: https://github.com/f5devcentral/f5-big-iq

Import AS3 BIG-IQ templates
^^^^^^^^^^^^^^^^^^^^^^^^^^^
1. Select **Import Templates** at the right top corner.

.. image:: ../pictures/module3/lab-1-2.png
  :scale: 60%
  :align: center

2. Make yourself familiar with the Github page and understand which AS3 templates are available.

3. When the AS3 templates are already imported in BIG-IQ you don’t need to perform next step, instead continue with the following step.

4. Use the provided instructions on the Github page to import the templates into BIG-IQ.

.. note:: The F5 default AS3 BIG-IQ templates are already imported in the lab environment.

5. Walk through the provided templates and select them to understand the structure. If familiar with AS3 you will notice the structure. 
   Otherwise go make sure you have gone through `Module 2`_ or visit `AS3 Example declarations`_.

.. _Module 2: ../module2
.. _AS3 Example declarations: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/userguide/examples.html.
