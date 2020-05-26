Lab 4: LTM conflict resolution: Silo in BIG-IQ
----------------------------------------------

**New BIG-IQ v7.1 Features**

BIG-IP configuration naming conventions are not consistent within many
customer environments. It is common to find similar names reused across
different BIG-IP’s for shared configuration objects such as Profiles,
Monitors etc.

When shared objects have the same name but different configurations this
creates a conflict within the centralized management system, and BIG-IQ
will raise an error and fail to import the BIG-IP device. In previous
releases you could either choose to override and rewrite what was on the
BIG-IP being imported with the configuration that was already in BIG-IQ,
or you could override the configuration that was in BIG-IQ with the
newly imported BIG-IP’s configuration.

Starting with BIG-IQ 7.1, you can now import devices with object naming
collisions into a temporary “silo” on BIG-IQ. This will allow you to
rename the configuration objects on BIG-IP using BIG-IQ. Once all of the
conflicting objects that need to remain unique have been renamed, the
device can be re-imported fully into BIG-IQ without the need for a silo.

In this lab, the Seattle device was imported first, and it has an object
named silo-lab-http-profile. The device’s profiles were imported into
the default Silo. Any update to that profile would be pushed out to all
devices that share the profile of the same name.

The San Jose BIG-IP device fails import due to a naming collision
because of a profile named silo-lab-http-profile (same name) but has
different configuration items within the profile. If you want to keep
the different configuration items for this device, you can now import it
into its own temporary silo to avoid conflict. You may then review the
configuration differences from BIG-IQ and push out naming changes to
resolve the conflict. The device can then be re-imported into BIG-IQ’s
default Silo because the naming conflict will have been removed.

|image50|

.. include:: ./accesslab.rst

Exercise 4.1 – Import a device into a Silo
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. From within the LAMP server RDP/noVNC session, logon to BIG-IQ as **david** *(david\\david)*
   by opening a browser and go to: ``https://10.1.1.4`` or directly via the TMUI.

2. Navigate to Devices > BIG-IP Devices. You can hide some columns you
   don’t need for this lab such as Stats Collection, Data Collection,
   Stats Last Collection by clicking on the wheel to the right of the
   *Filter…* field.

|image51|

3. Click on \ *Complete import
   tasks* under **SJC-vBIGIP01.termmarc.com** Services.

..

   |image52|

4. Click on Import to start the device configuration import into BIG-IQ.
   If prompted to re-discover the device before importing, go ahead and
   complete that step first, then Import.

..

   |image53|

5. The conflict resolution window opens. All the objects are given one
   of the following options, Set all BIG-IQ, Set all BIG-IP or Create
   Version with the exception of 1 object silo-lab-http-profile which
   only has the 2 first options.

..

   The HTTP profile silo-lab-http-profile already exists in BIG-IQ and
   is tied to one or more of the BIG-IP’s discovered & imported into
   BIG-IQ. In this case the Boston BIG-IP Cluster or the Seattle BIG-IP.

   If you choose BIG-IQ, the contents of this profile on the
   **SJC-vBIGIP01 BIG-IP** will get overwritten by what is already on
   BIG-IQ. This is likely not a preferred behavior because this is a
   working configuration and changing the content of the profile will
   likely break something.

   Choosing BIG-IP will overwrite the contents of this profile on BIG-IQ
   with what is being imported from this BIG-IP. This would then
   overwrite the configuration of the other BIG-IP’s that use this same
   shared object with the contents of the **SJC-vBIGIP01 BIG-IP**
   profile on the next deployment. This is also not a desired outcome as
   it will change working configurations on those devices.

   |image54|

6. Select the silo-lab-http-profile profile HTTP and note the difference
   between **BIG-IQ** and the **BIG-IP** device profile.

-  **BIG-IQ**

========================= ==========
   Accept XFF                Enabled
========================= ==========
   Insert X-Forwarded-For    Enabled
========================= ==========

-  **SJC-vBIGIP01.termmarc.com**

========================= ===========
   Accept XFF                Disabled
========================= ===========
   Insert X-Forwarded-For    Disabled
========================= ===========

..

   |image55|

   What you are noticing is a conflict between what BIG-IQ has stored
   for a profile named silo-lab-http-profile and what a profile of the
   same name has on the **SJC-vBIGIP01** device. They share the same
   name but have different configuration options enabled as highlighted
   in the display. Because we want to preserve both configurations and
   not overwrite BIG-IP or BIG-IQ for the conflicting HTTP profile,
   click on \ **Resolve Conflicts Later**.

7. Select \ **Create a New Silo** and name it silolab then
   click \ **Continue**

..

   |image56|

   The device is now imported into its own Silo named silolab. Note the
   object naming collision has not been resolved yet. Click \ **Close**.

   |image57|

   **Note**

   If you know all the devices from 1 data center have the exact same
   conflicts, you can put all of them in the same Silo rather than put
   each one into its own Silo.

8. Once the device is added to the Silo, import the device
   configuration.

..

   |image58|

9. After the Import has completed, go back to the BIG-IP Devices grid,
   you can see now \ **SJC-vBIGIP01.termmarc.com** has been imported
   into a Silo named silolab.

..

   |image59|

10. If you navigate to the Configuration tab > Local Traffic > Profile
    and filter on silo-lab-http-profile you will see the 2 different
    instances of the same HTTP profile. One which is part of the default
    Silo and the newly imported profile from the SJC BIG-IP device which
    is in the Silo called silolab.

..

   |image60|

Exercise 4.2 – Resolve conflicts in the Silo
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Navigate to \ **BIG-IP Device Silos** under the \ **Devices** menu
   and click on the silolab.

|image61|

2. Select Target Silo: \ **Default**, then click on \ **Compare Silos**.

|image62|

3. The comparison window opens. You can adjust the diff window with your
   cursor.

4. Scroll down and select Profile HTTP silo-lab-http-profile and look at
   the differences.

|image63|

Ignore the following diff:

1 "cm": {

2 "silo": "silolab"

3 },

The values of the Accept XFF and Insert X-Forwarded-For are different.
This is why the original import before adding to a Silo failed.

Silos are meant to be temporary so that an Admin can view and then
resolve conflicts. The ultimate goal is to be able to resolve any
conflicts from BIG-IQ and then remove this device from its Silo, and
eventually re-import back into the default Silo.

Let’s resolve the conflict by renaming the offending profile
from silo-lab-http-profile to silo-lab-http-profile2.

|image64|

Click \ **Save & Close**.

5. Wait for the renaming operation to complete. Then click \ **Close**.

|image65|

6. The previous step only made changes on BIG-IQ. You must now deploy
   the changes to the BIG-IP device. Navigate to the Deployment tab >
   Evaluate & Deploy > Local Traffic & Network.

|image66|

7. Create a new Evaluation, select the Silo silolab and set a name. Next
   move the **SJC-vBIGIP01** device from the \ **Available** box to
   the \ **Selected** box.

|image67|

Click \ **Create**.

8. After the evaluation completes, review the differences by clicking
   on \ **View**. BIG-IQ is going to deploy the new renamed profile and
   re-deploy the VIP with the new profile attached. Then, remove the old
   profile with the old name.

-  silo-lab-http-profile is removed

-  silo-lab-http-profile2 is added

-  silo-lab-http-profile is removed from the VIP vip-silo-lab

-  silo-lab-http-profile2 is attached to the VIP vip-silo-lab

|image68|

9. Now \ **Deploy** the changes to the BIG-IP.

|image69|

10. Navigate to the Configuration tab > Local Traffic > Profile and
    filter on silo-lab-http-profile to confirm the HTTP profile was
    renamed. The original conflict that prevented import into the
    default Silo has now been fixed, however the SJC BIG-IP device is
    still in its own Silo. The Next steps will remove the device from
    its own Silo and re-import into the default Silo.

|image70|

You can eventually go to the BIG-IP \ **SJC-vBIGIP01.termmarc.com** to
verify the profile has been renamed correctly.

Exercise 4.3 – Remove device from a silo and re-import it in BIG-IQ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now the necessary objects have been renamed on the BIG-IP, let’s remove
the device from its own Silo and re-discover and re-import it into
BIG-IQ.

1. From the Devices tab > BIG-IP Devices,
   select \ **SJC-vBIGIP01.termmarc.com** and click on \ **Remove All
   Services**

|image71|

Click on \ **Continue**.

|image72|

2. Once the services are removed, click on \ **Remove Device**.

|image73|

Click on \ **Remove**. You may need to refresh the page to see that it
has been deleted.

|image74|

3. Click on \ **Add Devices(s)** and fill below device information.

-  IP Address: 10.1.1.11

-  User Name: admin

-  Password: purple123

|image75|

4. The Service configuration & Statistic monitoring window will open.
   Select LTM and deselect DNS and AFM stats.

|image76|

Click on \ **Continue**.

5. Back on the Devices grid, click on \ *Complete import
   tasks* under **SJC-vBIGIP01.termmarc.com** Services.

|image77|

6. Click on Import to start the device configuration import in BIG-IQ.

|image78|

7. The conflict resolution window opens. Notice the profile
   HTTP silo-lab-http-profile is not showing anymore. Select \ **Create
   Version** option for all the remaining default profiles. The
   remaining conflicts are due to default changes in profiles across
   different TMOS versions. The \ **Version Specific Defaults** feature
   was added in a previous BIG-IQ release to deal with these sorts of
   conflicts. BIG-IQ will store different default values for each
   version of SW starting with what has been imported originally as the
   default. Next click \ **Continue** and if prompted
   click \ **Resolve** to address the version specific default
   conflicts.

|image79|

8. Once the import is completed, the device no longer shows silolab
   under Silo and \ *Management, LTM* in the device grid.

|image80|

9.  You can navigate to the Configuration tab > Local Traffic > Profile
    and filter on silo-lab-http-profile to confirm both HTTP
    profiles silo-lab-http-profile and silo-lab-http-profile2 were
    imported. Note a second copy of \ *silo-lab-http-profile2* still
    exists in the silolab Silo. Since this Silo is no longer in use it
    can be deleted.

10. Finally, the silo silolab can be removed from BIG-IQ. Go to Devices
    > BIG-IP Device Silos. You will notice that there are zero devices
    associated with that Silo. Select the silolab Silo, then
    click \ **Delete**. You may need to refresh the page to see that it
    is gone. That completes this lab.

|image81|

.. |image50| image:: images/lab4/image1.png
   :width: 5.58945in
   :height: 3.28261in
.. |image51| image:: images/lab4/image6.png
   :width: 6.5in
   :height: 2.86042in
.. |image52| image:: images/lab4/image7.png
   :width: 6.5in
   :height: 1.97292in
.. |image53| image:: images/lab4/image8.png
   :width: 6.5in
   :height: 2.57014in
.. |image54| image:: images/lab4/image9.png
   :width: 6.5in
   :height: 3.30764in
.. |image55| image:: images/lab4/image10.png
   :width: 6.5in
   :height: 3.30903in
.. |image56| image:: images/lab4/image11.png
   :width: 6.5in
   :height: 3.41875in
.. |image57| image:: images/lab4/image12.png
   :width: 6.25869in
   :height: 3.3032in
.. |image58| image:: images/lab4/image13.png
   :width: 6.5in
   :height: 1.98403in
.. |image59| image:: images/lab4/image14.png
   :width: 6.5in
   :height: 1.67222in
.. |image60| image:: images/lab4/image15.png
   :width: 6.5in
   :height: 2.31806in
.. |image61| image:: images/lab4/image16.png
   :width: 6.5in
   :height: 2.22153in
.. |image62| image:: images/lab4/image17.png
   :width: 6.5in
   :height: 3.64097in
.. |image63| image:: images/lab4/image18.png
   :width: 6.5in
   :height: 3.40417in
.. |image64| image:: images/lab4/image19.png
   :width: 6.5in
   :height: 3.44514in
.. |image65| image:: images/lab4/image20.png
   :width: 6.48677in
   :height: 3.50505in
.. |image66| image:: images/lab4/image21.png
   :width: 6.5in
   :height: 2.67986in
.. |image67| image:: images/lab4/image22.png
   :width: 6.5in
   :height: 3.36319in
.. |image68| image:: images/lab4/image23.png
   :width: 6.5in
   :height: 3.31944in
.. |image69| image:: images/lab4/image24.png
   :width: 6.49548in
   :height: 2.63359in
.. |image70| image:: images/lab4/image25.png
   :width: 6.5in
   :height: 2.8875in
.. |image71| image:: images/lab4/image26.png
   :width: 6.5in
   :height: 3.08472in
.. |image72| image:: images/lab4/image27.png
   :width: 6.5in
   :height: 3.01528in
.. |image73| image:: images/lab4/image28.png
   :width: 6.5in
   :height: 2.90764in
.. |image74| image:: images/lab4/image29.png
   :width: 6.5in
   :height: 3.02847in
.. |image75| image:: images/lab4/image30.png
   :width: 6.5in
   :height: 4.68264in
.. |image76| image:: images/lab4/image31.png
   :width: 6.5in
   :height: 6.88194in
.. |image77| image:: images/lab4/image32.png
   :width: 6.5in
   :height: 1.52708in
.. |image78| image:: images/lab4/image33.png
   :width: 6.5in
   :height: 2.57847in
.. |image79| image:: images/lab4/image34.png
   :width: 6.5in
   :height: 3.28056in
.. |image80| image:: images/lab4/image35.png
   :width: 6.5in
   :height: 1.23125in
.. |image81| image:: images/lab4/image36.png
   :width: 6.5in
   :height: 3.80208in
