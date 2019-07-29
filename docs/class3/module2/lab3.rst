Lab 2.3: Troubleshooting Application Response Time Browser
----------------------------------------------------------
Connect as **paul**.

1. Select application ``site42.example.com`` and turn on **Enhanced Analytics**, click on the button at the top right of the screen, and click on **Start**.

The Enhanced Analytics allows you to increase the application data visibility by collecting additional data for all, or specific, client IP addresses sending requests to the application.

.. note:: When this option is enabled, a banner appears at the top of the screen and highlights the application health icon in the applications list. Enhanced Analytics might be already turn on for site42.example.com

2. From UDF, launch a Console/RDP session to have access to the Ubuntu Desktop. To do this, in your UDF deployment, click on the *Access* button
of the *Ubuntu Lamp Server* system and select *Console* or *XRDP*

.. image:: ../../pictures/udf_ubuntu.png
   :align: center
   :scale: 50%

|

You can use the copy/past feature if you are using the Console:

.. image:: ../../pictures/ubuntu_console.png
   :align: center
   :scale: 50%

|

Open Chrome and Firefox and navigate on the website https://site42.example.com/f5_browser_issue.php.

.. note:: Go firt to https://site42.example.com to accept the private certificates.

A page f5_browser_issue.php is behaving differenty on Chrome compare to other browsers.

.. image:: ../pictures/module2/img_module2_lab3_1.png
   :align: center
   :scale: 50%

|

3. Back to BIG-IQ Application dashboard, open application ``site42.example.com`` and display the *Application Response Time* Analytics.

Expand the right-edge of the analytics panel to get the URLs and Browser filters. Order the URLs by App Response Time Average.

.. image:: ../pictures/module2/img_module2_lab3_2.png
   :align: center
   :scale: 50%

|

If the Application Response Time column, click right on the blue portion of the table, select Columns, then select Avg under the Application Response Time:

.. image:: ../pictures/module2/img_module2_lab3_2a.png
   :align: center
   :scale: 50%

|

Select the page f5_browser_issue.php, which has the highest value. Now all the values in all the other tables are about the page previously selected.

In the Browsers filter, notice the 30 sec Application Response Time for Chrome browser.

.. image:: ../pictures/module2/img_module2_lab3_3.png
   :align: center
   :scale: 50%
