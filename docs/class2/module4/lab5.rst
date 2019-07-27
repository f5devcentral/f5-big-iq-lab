Lab 4.5: Cleanup the environment (AWS)
--------------------------------------

Once you are done with your demo/training/testing, you will want to cleanup your
environment.

.. warning:: REMEMBER that this lab has a cost in AWS. You must make sure to tear down
  your environment as soon as you're done with it

.. warning:: The SSG will be automatically delete 23h after the deployment was started.

To do this, please proceed this way: Connect to your system called
**Ubuntu Lamp Server**

Do the following:

.. code::

    f5student@xjumpbox:~$ cd f5-aws-vpn-ssg/
    f5student@xjumpbox:~/f5-aws-vpn-ssg$ nohup ./111-DELETE_ALL.sh ssg &
    f5student@xjumpbox:~/f5-aws-vpn-ssg$ tail -f nohup.out

Follow all the steps as explained:

* Delete the app deployed on your AWS ``SSG`` from the ``BIG-IQ UI`` and then press ENTER
* Delete the AWS ``SSG`` from the ``BIG-IQ UI`` and then press Enter

...

.. image:: ../pictures/module4/img_module4_lab5_1.png
  :align: center
  :scale: 50%

|

If you go monitor your ``AWS Stacks`` in the ``AWS Console``, you'll see the stacks
previously created being removed

In the end, your ``AWS VPC`` and all the related components should be removed .
