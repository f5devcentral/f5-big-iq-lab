API Rest Client in Visual Studio Code
=====================================

In case you need to use an API Rest Client for this lab, follow below instructions to use the **REST Client for Visual Studio Code**.

1. Open Visual Studio Code in the **Ubuntu Jumphost** and open the extensions menu, click on **REST Client** extension 
   and go through the details section to get familiar with the extension.

.. image:: /pictures/rest_client-01.png
  :scale: 40%
  :align: center


2. Back on the Explorer tab in VS code, navigate under ``project`` folder and open ``postman.rest`` (the file might be already open).

The ``postman.rest`` is a file with a number of BIG-IQ Rest call examples. You will find the BIG-IQ IP address under ``#My Variables`` section at the top of the file.

In order to authenticate to the BIG-IQ, click on *Send Request* below the URL.

.. image:: /pictures/rest_client-02.png
  :scale: 40%
  :align: center

3. The response window will open to the right side and the F5 authentication token will be automatically saved in the ``f5_token`` variable defined in the file.

.. image:: /pictures/rest_client-03.png
  :scale: 40%
  :align: center

.. note:: The token timeout in BIG-IQ is set by default to **5 min**. If you get 401 Invalid registered claims, request a new token.

4. Once your are authenticated to the BIG-IQ, you can send POST or GET requests described in the lab guide.
   You may use the examples listed below the one authenticating to the BIG-IQ.