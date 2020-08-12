Lab 1.1: Move a certificate from unmanaged to managed state
------------------------------------------------------------

.. note:: Estimated time to complete: **15 minutes**

.. include:: /accesslab.rst

Import all Certificates & keys from a device or multiple devices
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Login as **david** in BIG-IQ. At the top of the screen, click Configuration.

2. On the left, click LOCAL TRAFFIC > Certificate Management > Certificates & Keys. These are the imported from BIG-IP but not yet managed by BIG-IQ.

.. image:: media/img_module1_lab1-1.png
  :scale: 40%
  :align: center

3. Click on **Import**, then select *Import from BIG-IP Devices*.

4. Select **SEA-vBIGIP01.termmarc.com**, enter device login and password (default user is root, password ``purple123``), check the box *Retrieve All Objects*.

.. image:: media/img_module1_lab1-2.png
  :scale: 40%
  :align: center

Click on the **Import**

5. After clicking on import, you will be taking back to the list of Certificates & Keys and should see the certificates & keys from **SEA-vBIGIP01.termmarc.com** being managed.

.. image:: media/img_module1_lab1-3.png
  :scale: 40%
  :align: center

6. If you come back from the previous page, click on **Import**, then select *Import from BIG-IP Devices*, you can see the status and time of the last import.

.. image:: media/img_module1_lab1-4.png
  :scale: 40%
  :align: center

.. note:: If you like to automate the import of Certificate and Key, read the following devcentral article `Automate import of SSL Certificate, Key & CRL from BIG-IP to BIG-IQ`_.

.. _Automate import of SSL Certificate, Key & CRL from BIG-IP to BIG-IQ: https://devcentral.f5.com/s/articles/automate-import-of-ssl-certificate-key-crl-from-big-ip-to-big-iq-31899

Import a single Certificate & Key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Login as **david** in BIG-IQ. At the top of the screen, click Configuration.

2. On the left, click LOCAL TRAFFIC > Certificate Management > Certificates & Keys. These are the imported from BIG-IP but not yet managed by BIG-IQ.

|image1|

3. Click the name of the unmanaged certificate **f5-ca-bundle**. You will need to import the certificate from the managed BIG-IP.

|image2|

Before you can import the certificate to BIG-IQ, you will need to export certificate/key from the managed BIG-IP device.

4. Log onto the TMUI interface of the **BOS-vBIG-IP01.temmarc.com** device to export the certificate/key pair.

Click System ›› Certificate Management ›› Traffic Certificate Management ›› SSL Certificate List ›› f5-ca-bundle

|image3|

Click Export and then click on **Download f5-ca-bundle.crt** button to save the certificate to a file to a location that you can easily locate.

|image4|

After saving the certificate file, click Cancel button to go back to previous screen.

5. Now, circle back to the BIG-IQ CM TMUI and go back to the Certificate Properties: State setting, click the Import button and then:

-  To upload the certificate's file, select Upload File and click the Choose File button to navigate to the certificate file you saved before.

|image5|

Since this is a bundled certificate/key pair, you do not need to separately import the key file.

7. Click the Save & Close button. Your certificate/key pair is now **Managed** by BIG-IQ.

|image6|


.. |image1| image:: media/image1.png
   :width: 6.50000in
   :height: 1.82917in
.. |image2| image:: media/image2.png
   :width: 6.49583in
   :height: 3.38750in
.. |image3| image:: media/image3.png
   :width: 6.49583in
   :height: 4.02083in
.. |image4| image:: media/image4.png
   :width: 6.49583in
   :height: 3.14583in
.. |image5| image:: media/image5.png
   :width: 6.49167in
   :height: 3.06250in
.. |image6| image:: media/image6.png
   :width: 6.49167in
   :height: 1.82083in
