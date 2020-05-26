Lab 1.4: Uploading QKviews to iHealth for a support case
--------------------------------------------------------

BIG-IQ can now push qkviews from managed devices to ihealth.f5.com and
provide a report of heuristic hits based on the qkview. These qkview
uploads can be performed ad-hoc or as part of a F5 support case. If a
support case is specified in the upload job, the qkview(s) will
automatically be associated/linked to the support case.

.. warning:: Re-license BIG-IQ CM with an Eval License in order to run this lab.

1. Navigate to **Monitoring** on the top menu bar and then to
   **REPORTS-> Device-> iHealth** -> **Configuration** on the left-hand
   menu\ **.**

   |image93|

2. Add Credentials to be used for the qkview upload and report
   retrieval. Click the Add button under Credentials.

   |image94|

3. | Fill in the credentials that you used to access
     https://ihealth.f5.com :
   | Name: **Give the credentials a name to be referenced in BIG-IQ**
   | Username: **<Username you use to access iHealth.f5.com>**
   | Password: **<Password you use to access iHealth.f5.com**>

4. Click the Test button to validate that your credentials work.

   |image95|

5. Click the **Save & Close** button in the lower right.

6. Click the **Tasks** button in the BIG-IQ iHealth menu.

   |image96|

7. Click the **QKView Upload** button to select which devices we need to
   upload QkViews from:

   |image97|

8. | Fill in the fields to upload the QkViews to iHealth.
   | Name: **QKViewUpload5346** (append the last 4 digits of your cell
     number to make this request unique)
   | Credentials: **<Select the credentials you just stored in step 5>**
   | Devices: Select **SEA-vBIGIP01.termmarc.com**

   |image98|

1. Click the **Save & Close** button in the lower right. The task will
   be started immediately.

   \*Note that you can also schedule QKview uploads on a regular basis
   using the **QKView Upload Schedules** on the left menu bar

2. Click on the name of your upload job to get more details

   |image99|

3. Observe the progress of the Qkview creation, retrieval, upload,
   processing, and reporting. This operation can take some time, so you
   may want to move on to the next exercise and come back.

4. Once a job reaches the Finished status, click on the Reports menu to
   review the report.

   |image100|

5. Select the report you just created and click the **Open** hyperlink
   under the Report Column

   |image101|


   .. |image93| image:: media/image91.png
      :width: 5.94973in
      :height: 4.06557in
   .. |image94| image:: media/image92.png
      :width: 1.88518in
      :height: 0.92697in
   .. |image95| image:: media/image93.png
      :width: 3.62295in
      :height: 2.27173in
   .. |image96| image:: media/image94.png
      :width: 1.93125in
      :height: 1.26279in
   .. |image97| image:: media/image95.png
      :width: 1.93125in
      :height: 1.06679in
   .. |image98| image:: media/image96.png
      :width: 6.38198in
      :height: 2.57377in
   .. |image99| image:: media/image97.png
      :width: 2.82256in
      :height: 0.74991in
   .. |image100| image:: media/image98.png
      :width: 1.93125in
      :height: 1.35353in
   .. |image101| image:: media/image99.png
      :width: 6.49097in
      :height: 1.23125in

