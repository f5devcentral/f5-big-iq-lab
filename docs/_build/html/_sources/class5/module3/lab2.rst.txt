Lab 3.1: Create a backup schedule
---------------------------------

Now, we can create our backup schedule that references this dynamic group.

1. Click on the Back Up & Restore on the left-hand menu

2. Click on Backup Schedules

|image22|

3. Click the Create button in the main pane

4. Fill out the Backup Schedule

+--------------------------+------------------------------------------------------+
| Name                     | **BostonNightly**                                    |
+==========================+======================================================+
| Local Retention Policy   | **Delete local backup copy 3 days after creation**   |
+--------------------------+------------------------------------------------------+
| Backup Frequency         | **Daily**                                            |
+--------------------------+------------------------------------------------------+
| Start Time               | 00:00 Eastern Standard Time                          |
+--------------------------+------------------------------------------------------+

Under Devices, select the **Groups radio button**

Select from the drop-down **BostonDCGroup**

In the Backup Archive section, enter the following:

+-------------+------------------------------------+
| Archive     | **Store Archive Copy of Backup**   |
+=============+====================================+
| Location    | **SCP**                            |
+-------------+------------------------------------+
| User name   | **F5**                             |
+-------------+------------------------------------+
| Password    | **default**                        |
+-------------+------------------------------------+
| Directory   | **/home/f5**                       |
+-------------+------------------------------------+

|image23|

|image24|

Click Save & Close to save the scheduled backup job.


.. |image22| image:: media/image22.png
   :width: 2.28096in
   :height: 1.23943in
.. |image23| image:: media/image23.png
   :width: 6.35479in
   :height: 5.69259in
.. |image24| image:: media/image24.png
   :width: 6.50000in
   :height: 2.21319in
