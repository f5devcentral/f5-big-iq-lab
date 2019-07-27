Lab 5.5: Cleanup the environment (Azure)
----------------------------------------

Once you are done with your demo/training/testing, you will want to cleanup your
environment.

.. warning:: REMEMBER that this lab has a cost in Azure. You must make sure to tear down
  your environment as soon as you're done with it

.. warning:: The SSG will be automatically delete 23h after the deployment was started.

To do this, please proceed this way: Connect to your system called
**Ubuntu 18.04 Lamp Server**

Do the following:

.. code::

    f5@03a920f8b4c0410d8f:~$ cd f5-azure-vpn-ssg/
    f5@03a920f8b4c0410d8f:~/f5-azure-vpn-ssg$ nohup ./111-DELETE_ALL.sh &
    f5@03a920f8b4c0410d8f:~/f5-azure-vpn-ssg$ tail -f nohup.out

Follow all the steps as explained:

* Delete the app deployed on your Azure ``SSG`` from the ``BIG-IQ UI`` and then press ENTER
* Delete the Azure ``SSG`` from the ``BIG-IQ UI`` and then press Enter

If you go monitor your ``Resource Groups`` in the ``Azure Console``, you'll see the objects
previously created being removed.

In the end, your ``Azure VNET`` and all the related components should be removed .
