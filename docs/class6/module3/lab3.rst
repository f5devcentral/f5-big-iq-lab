Lab 3.3: Create iRule and attach to multiple virtual servers
------------------------------------------------------------

BIG-IQ allows users to create iRules and use them on the virtual servers that are managed by BIG-IQ. The iRules can be attached to individual virtual servers or iRules can be attached to multiple virtual servers in the same operation.

In this scenario, we will apply an iRule to a number of our virtual servers that presents a maintenance page if none of the pool members supporting the virtual are online and available.

You can create an iRule on the BIG-IQ directly.

To save time the **VS\_maintenance\_irule** has already been created on the BIG-IQ.

1. Steps 1-5 show that you can create an iRule on the BIG-IQ directly.

To save time the **VS\_maintenance\_irule** has already been created on the BIG-IQ.

.. note:: Skip to step 6 to apply the already configured iRule, or you may create your own iRule for this lab.


2. Navigate to the **Configuration** tab on the top menu bar.

3. Select **LOCAL TRAFFIC > iRules**

|image24|

4. Click the Create button under iRules

|image25|

5. Fill out the iRule Properties page
   | Name: **VS\_maintenance\_irule**
   | Partition: **Common**
   | body: as below:

when RULE\_INIT {
# sets the timer to return client to host URL
set static::stime 10
}

when CLIENT\_ACCEPTED {
set default\_pool [LB::server pool]
}

when HTTP\_REQUEST {
# Check if the URI is /maintenance
switch [HTTP::uri] {

"/maintenance" {

# Send an HTTP 200 response with a Javascript meta-refresh pointing to the host using a refresh time
HTTP::respond 200 content \\
"<html><head><title>Maintenance page</title></head><body><metahttp-equiv='REFRESH' content=$static::stime;url=[HTTP::uri]></HEAD>\\
<p><h2>Sorry! This site is down for maintenance.</h2></p></body></html>" "Content-Type" "text/html"
return
}
}

# If the default pool is down, redirect to the maintenance page
if { [active\_members $default\_pool] < 1 } {
HTTP::redirect "/maintenance"
return
}
}

|image26|

6. | Navigate to **LOCAL TRAFFIC > Virtual Servers**

|image27|

Type ITwiki in the filter box on the right hand side of the screen and press return.

|image28|

| Click to select all the matching virtual servers

|image29|


Click the **Attach iRules** button at the top of the screen

|image30|

Fill out the Attach iRules section
   | iRules: Select the **VS\_maintenance\_irule** iRule

|image31|

Click **Save & Close** in the lower right.

Clear the filter from the Virtual Servers

|image32|

.. |image24| image:: media/image24.png
   :width: 2.34346in
   :height: 1.44774in
.. |image25| image:: media/image25.png
   :width: 1.12486in
   :height: 1.02071in
.. |image26| image:: media/image26.png
   :width: 6.50000in
   :height: 2.42917in
.. |image27| image:: media/image16.png
   :width: 2.32263in
   :height: 0.78115in
.. |image28| image:: media/image27.png
   :width: 3.43707in
   :height: 0.69783in
.. |image29| image:: media/image28.png
   :width: 6.50000in
   :height: 3.04375in
.. |image30| image:: media/image29.png
   :width: 3.18125in
   :height: 0.98529in
.. |image31| image:: media/image30.png
   :width: 6.50000in
   :height: 3.36181in
.. |image32| image:: media/image31.png
   :width: 2.91630in
   :height: 1.41649in