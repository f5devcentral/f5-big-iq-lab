Lab 2.5: Test access privileges for the user with the custom role
-----------------------------------------------------------------

Test user nsadmin on the access privileges for the custom resource groups assigned.

1. Log out the admin user from the right upper corner, and log back into the BIG-IQ with the user “nsadmin” and password “nsadmin”, and select **Local** from Auth Provider list.

|image13|

2. Click on upper left tab “Configuration”, select **Security > Network Security > Rule Lists** and select any rule from the list.

**Note** that you do not have option/permission to delete a Rule List object.

|image14|

1. Select Address Lists on the left and select any address list object.

**Note** that you also **do not have** permission to delete an address list.

|image15|

1. Select Port List on the left and select any entry in the list.

   **Note** that you **do have** the permission to Clone, Delete and Rename the object.

|image16|




.. |image13| image:: media/image13.png
   :width: 6.49167in
   :height: 2.30000in
.. |image14| image:: media/image14.png
   :width: 6.50000in
   :height: 3.65625in
.. |image15| image:: media/image15.png
   :width: 6.50000in
   :height: 3.20833in
.. |image16| image:: media/image16.png
   :width: 6.49167in
   :height: 3.21667in

