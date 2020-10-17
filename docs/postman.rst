API Rest Client: Postman
========================

In case you need to use an API Rest Client for this lab, follow below instruction to configure the **Postman Google Chrome Extension**.

1. Open Google Chrome in the **Ubuntu Jumphost** and click on the link **Install Postman**.

.. image:: /pictures/postman_install-01.png
  :scale: 40%
  :align: center

2. Click on **Add Extension**

.. image:: /pictures/postman_install-02.png
  :scale: 40%
  :align: center

3. After few seconds, the extension has been added to the browser and available when clicking on the blue icon on top right of the window.

.. image:: /pictures/postman_install-03.png
  :scale: 40%
  :align: center

4. Now, let's import some collection available for the labs. Click on **Collections** on the left menu, then **Import Collections**.

.. image:: /pictures/postman_install-04.png
  :scale: 40%
  :align: center

5. Choose the collection file called ``postman_collection.json``.

.. image:: /pictures/postman_install-05.png
  :scale: 40%
  :align: center

|

.. image:: /pictures/postman_install-06.png
  :scale: 40%
  :align: center

6. Then, import environment **BIG-IQ lab**. In the middle of the window at the top, click **Manage environments**.

.. image:: /pictures/postman_install-07.png
  :scale: 40%
  :align: center

7. Click Import, then select ``postman_env.json``

.. image:: /pictures/postman_install-08.png
  :scale: 40%
  :align: center

| 

.. image:: /pictures/postman_install-09.png
  :scale: 40%
  :align: center

8. Once the import is done, click on **Back**.

.. image:: /pictures/postman_install-10.png
  :scale: 40%
  :align: center

9. Now, select the **BIG-IQ Lab** environment. This will be used to store the authentication token used to make the future API calls to BIG-IQ.

.. image:: /pictures/postman_install-11.png
  :scale: 40%
  :align: center

10. Because the BIG-IQ in his lab has a private SSL certificate, let's open a new tab and accept the BIG-IQ certificate by navigating to ``http://10.1.1.4``. 

.. image:: /pictures/postman_install-12.png
  :scale: 40%
  :align: center

11. Back in postman, click on the postman collection **BIG-IQ token**, click on **Send**.

.. image:: /pictures/postman_install-13.png
  :scale: 40%
  :align: center

12. Click on **Allow**.

.. image:: /pictures/postman_install-14.png
  :scale: 40%
  :align: center

13. Select the BIG-IQ token, click right, then **Copy**.

.. image:: /pictures/postman_install-15.png
  :scale: 40%
  :align: center

14. Open the **BIG-IQ Lab** environment.

.. image:: /pictures/postman_install-16.png
  :scale: 40%
  :align: center

| 

.. image:: /pictures/postman_install-17.png
  :scale: 40%
  :align: center

15. Past the value of the BIG-IQ token ``_f5_token``.

.. image:: /pictures/postman_install-18.png
  :scale: 40%
  :align: center

16. Click on **Submit**.

.. image:: /pictures/postman_install-19.png
  :scale: 40%
  :align: center

.. note:: The token timeout in BIG-IQ is set by default to **5 min**. If you get 401 Invalid registered claims, request a new token and update the ``_f5_token`` variable in the **BIG-IQ Lab** environment.

17. You can see the value of the token by clicking on the *eye* next to the **BIG-IQ Lab** environment.

.. image:: /pictures/postman_install-20.png
  :scale: 40%
  :align: center

18. The ``_f5_token`` variable is set in the other postman collections to assure authentication to the BIG-IQ. You may past the new value of the token directly in the other collection and not use the environment variables.

.. image:: /pictures/postman_install-21.png
  :scale: 40%
  :align: center
