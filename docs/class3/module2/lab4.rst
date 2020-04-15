Lab 2.4: Troubleshooting 503 Service Unavailable
------------------------------------------------
1. Login as **paula** in BIG-IQ.

2. Select the application service ``security_site16_boston`` located under ``airport_security`` application.

3. Let's generate additonnal traffic to the application ``security_site16_boston``, connect on the *Ubuntu Lamp Server* and launch the following command:

``# /home/f5/f5-demo-app-troubleshooting/503.sh``

4. Back to BIG-IQ Application dashboard, ``security_site16_boston`` and display the *Transaction* Analytics.

- Click Expand the right-edge of the analytics panel to get the filters.
- Move the *URLs* and the *Response Codes* tables next to each other and expand them both (the tables can be moved up/down).
- In the *Response Codes* table, select the *200* and *503* lines.
- Click right on the *Response Codes* and click on *Add Comparison Chart*.

.. image:: ../pictures/module2/img_module2_lab4_1.png
   :align: center
   :scale: 60%

|

5. Finally, only select the *503* error in the filters and notice the page *f5_capacity_issue.php* shows up.

It appears from the data showing on BIG-IQ the application may start having issue (error 503) when 
there are more traffic going through it.

.. image:: ../pictures/module2/img_module2_lab4_2.png
   :align: center
   :scale: 60%

|

Using the data available in BIG-IQ Application dashboard, we can narrow down 503 error 
and troubleshoot the inability of an application to handle production data capacities.
