Lab 6.1: Configure a new DCD and setup 2 different zones
--------------------------------------------------------

Using the UDF/Ravello network below, the goal is to configure the BIG-IQ management console and DCD1 in the ``default`` zone.
The DCD2 at the other location will be in zone ``westcoast``. The BIG-IPs will be assign to the approriate zone depending on their location.

.. image:: ../pictures/module6/img_module6_lab1_diagram.png
  :align: center
  :scale: 50%

|

1. Let's first add a BIG-IQ DCD image in the blueprint.

- In UDF:

In the ``F5 Products`` column, click on **ADD**

.. image:: ../pictures/module6/img_module6_lab1_1a.png
  :align: center
  :scale: 70%

|

Select approriate release of BIG-IQ (same as the existing active BIG-IQ part of the blueprint) and set the following values for CPU/Memory/Disk:

    - vCPUs: 4
    - Memory: 16 GiB
    - Disk Size: 500 GiB

Click on **CREATE**.

.. image:: ../pictures/module6/img_module6_lab1_1b.png
  :align: center
  :scale: 70%

|

After few minutes, the VM is created in UDF. Click on the new VM, go to the Subnets tab and bind additional interfaces (External and Internal).

.. image:: ../pictures/module6/img_module6_lab1_1c.png
  :align: center
  :scale: 70%

|

Finally, start the new BIG-IQ.

.. image:: ../pictures/module6/img_module6_lab1_1d.png
  :align: center
  :scale: 70%

|

- In Ravello:

In the top left, click on the **+** sign and search for BIG-IQ 6.1 CM VM image.

.. image:: ../pictures/module6/img_module6_lab1_2a.png
  :align: center
  :scale: 70%

|

Add the image into the deployment.

.. image:: ../pictures/module6/img_module6_lab1_2b.png
  :align: center
  :scale: 70%

|

Got to the network tab and fix the IP addresses using ``10.1.1.13``, ``10.1.10.13`` and ``10.1.20.13``. Click on **Update**

.. image:: ../pictures/module6/img_module6_lab1_2c.png
  :align: center
  :scale: 70%

|

Then, start the new BIG-IQ DCD VM.

2. Connect via ``SSH`` to the system *Ubuntu Lamp Server*.

3. Request 1 BIG-IQ Evaluation license and set it in the inventory file in ``bigiq_onboard_license_key`` variable (**Ravello only**).

    ::

        # cd /home/f5/f5-ansible-bigiq-onboarding 
        # vi inventory/group_vars/udf-bigiq-dcd-02.yml

.. note:: Double check the IP address of the new secondary BIG-IQ and update it in ``udf-bigiq-dcd-02.yml`` if necessary (``bigiq_onboard_server``)

4. Once the new VE is full up and running, execute the following script to onboard this new secondary BIG-IQ CM.

    ::

        # cd /home/f5/f5-ansible-bigiq-onboarding
        # ./cmd_bigiq_onboard_secondary_dcd.sh nopause


5. Verify the new secondary BIG-IQ DCD has been correctly added to the BIG-IQ Data Colletion Devices list.

.. image:: ../pictures/module6/img_module6_lab1_3.png
  :align: center
  :scale: 70%

|

6. Currently, there is only 1 zone defined called ``default``. We will create a new zone called ``westcoast``, keeping the ``default`` zone for the East coast.

.. note:: In order to avoid error messages complaining about the lack of a default zone, you must have one DCD at minimum have the default zone.

7. Let's define the new zone ``westcoast`` on the new BIG-IQ DCD 02 added earlier. Login on the BIG-IQ CM server, go to the **System** tab, 
   under **BIG-IQ DATA COLLECTION** > **BIG-IQ Data Collection Devices**, select the new BIG-IQ DCD 02. In **Properties**, and click **Edit**, select the Zone box, click **Create New**.

   Enter the name ``westcoast`` as the name of the new Zone.

.. image:: ../pictures/module6/img_module6_lab1_4.png
  :align: center
  :scale: 70%

|

It might takes few minutes for the new zone to be set.

.. image:: ../pictures/module6/img_module6_lab1_5.png
  :align: center
  :scale: 70%

|

8. Change the Zone of the ``SEA-vBIGIP01.termmarc.com`` and ``SJC-vBIGIP01.termmarc.com`` BIG-IP to ``westcoast``.

Select the BIG-IP device from the **Devices** menu, and select **STATISTICS COLLECTION**. 

Once selected, select ``westcoast`` from the Zone drop down menu.

It might takes few minutes for the new zone to be set.

.. image:: ../pictures/module6/img_module6_lab1_6.png
  :align: center
  :scale: 70%

|

9. Check on the Device tab the statistic collection is happening as expected.

.. image:: ../pictures/module6/img_module6_lab1_7.png
  :align: center
  :scale: 70%

|
