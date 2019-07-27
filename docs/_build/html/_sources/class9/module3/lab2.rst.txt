Lab 1.2: Create a new VPN Access profile
----------------------------------------

-  Navigate to ConfigurationAccessAccess Groups

-  Select BostonAG

|image24|

You can see all of the access policies listed in the Per Session
Policies:

|image25|

Click Create and you will see the Access Policy creation screen. Give it
a name of “VPN-AP” and click on **Save & Close**. You can change the
view from Basic -> Advanced if you want to modify additional settings
such as timeouts, SSO, logout URI, etc..

|image26|

Then click “New” in macros and select “AD Auth and resources” template.
Then click the “OK” button.

|image27|

Click on the AD Auth object and use the Server drop down to select
FrogPolicy-olympus-ad then click Save.

|image28| |image29|

Now click the Resource Assign object. In the pop up window click the Add
button. Expand the Network Access section and move the
/Common/FrogPolicy-F5\_VPN from the Available section to the Selected
section and click the Save button.

|image30|

The result will look like the picture below, click the Save button on
this screen.

|image31|

Then add the macro into the VPE by hovering mouse over blue line and
selecting the Green plus sign. Then change the ending on the
“Successful” branch to **Allow**. Then click Save buttons to complete.

|image32|\ |image33|

|image34|

After creating and saving the access profile, go to “Deployment - >
Evaluate & Deploy -> Access”.

Click on “Create” in Evaluations, give it a name, and select
BOS-vBIGIP01/02 devices.

|image35|

Click on View after the evaluation is done to view the changes in Green.

|image36|

|image37|

Then Click on Deploy and verify the new VPN Access Profile is pushed
onto the BIG-IP device BOS01.

|image38|

|image39|

.. |image24| image:: media/image24.png
   :width: 4.65572in
   :height: 1.92569in
.. |image25| image:: media/image25.png
   :width: 6.50000in
   :height: 2.40619in
.. |image26| image:: media/image26.png
   :width: 6.50000in
   :height: 2.50820in
.. |image27| image:: media/image27.png
   :width: 4.68368in
   :height: 1.79508in
.. |image28| image:: media/image28.png
   :width: 2.02459in
   :height: 1.45833in
.. |image29| image:: media/image29.png
   :width: 2.40984in
   :height: 2.40984in
.. |image30| image:: media/image30.png
   :width: 4.45082in
   :height: 2.90920in
.. |image31| image:: media/image31.png
   :width: 5.20370in
   :height: 2.30328in
.. |image32| image:: media/image32.png
   :width: 2.23084in
   :height: 1.94221in
.. |image33| image:: media/image33.png
   :width: 2.32787in
   :height: 2.07099in
.. |image34| image:: media/image34.png
   :width: 6.50000in
   :height: 3.47222in
.. |image35| image:: media/image35.png
   :width: 6.49097in
   :height: 3.44444in
.. |image36| image:: media/image36.png
   :width: 6.49097in
   :height: 1.23770in
.. |image37| image:: media/image37.png
   :width: 6.48125in
   :height: 2.13934in
.. |image38| image:: media/image38.png
   :width: 6.48125in
   :height: 2.35208in
.. |image39| image:: media/image39.png
   :width: 6.50000in
   :height: 2.56557in