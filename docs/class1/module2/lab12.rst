Lab 2.12: AS3 Application Creation using GitLab CI/CD pipeline, Ansible and BIG-IQ
----------------------------------------------------------------------------------

.. note:: Estimated time to complete: **25 minutes**

In this lab, we are going to use GitLab to store the BIG-IP configuration (AS3 declaration) and deploy it through BIG-IQ to BIG-IP.
We are leveraging a **CI/CD pipeline** in GitLab in order to make changes on the BIG-IP device.

Gitlab will keep track of the changes and control **user access** to the application service configuration of the F5 BIG-IP.
We are using BIG-IQ to provide **visibility with enhanced analytics** (HTTP/TCP) to the DevOps/Application owner.

This lab will be using following F5 Ansible Galaxy role:
    - `atc_deploy`_  **ansible Role**: Allows AS3 declaration to be sent to `automation tool chain`_ service.

.. _atc_deploy: https://galaxy.ansible.com/f5devcentral/atc_deploy
.. _automation tool chain: https://www.f5.com/products/automation-and-orchestration

.. include:: /accesslab.rst

Start GitLab and create new a project
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Connect via ``SSH`` to the system *Ubuntu Lamp Server*.

2. Execute the playbook::

    # export GITLAB_HOME="~/gitlab/"
    # docker-compose -f ~/gitlab/docker-compose.yml up -d

3. Wait 5min to open GitLab web UI from the lab environement. Click on the *ACCESS* button of the **Ubuntu Lamp Server** system and click on
   *GitLab*. The login/password is ``root/purple123``. Or open ``http://localhost:7002`` from a brownser in the jumphost.

|lab-12-1|

4. Create a new project and name it ``mywebapp``.

|lab-12-2|

|lab-12-3|

5. Copy the jumphost *Ubuntu Lamp Server* ssh public key::

    # cat ~/.ssh/id_rsa.pub 

6. Back in GitLab, click on **Add SSH Key**.

|lab-12-4|

Paste the public key and click om **Add Key**.

|lab-12-5|

7. Let's now configure the gitlab runner with this project.
   This runner will be used to trigger pipelines when a commit is done on the project and allow us to automatically trigger a set of tasks.
   
First Let's open your project, click **Your Projects**.

|lab-12-6|

Click on ``mywebapp``.

|lab-12-7|

Navigate the CI/CD option copy the token value.

Click on Settings > CI/CD.

|lab-12-8|

Find and expand the **Runner** section.

|lab-12-9|

Finally copy the token value.

|lab-12-10|

8. Back in the Linux jumphost, run the following command to register the gitlab runner using the token value::

    # ./gitlab/gitlab-runner-register.sh <token>

9. In GitLab, confirm the GitLab runner is correctly attached to your project. Navigate to the same location where you copy the token.

Clone gitlab project and deploy AS3 HTTP application service to a BIG-IP through BIG-IQ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. From the linux jumphost, clone the repository::

    # git clone ssh://git@localhost:7022/root/mywebapp.git
    # cd mywebapp

2. Or order to be able to commit and push changes, we will need to configure the user email and name in git::

    # git config --global user.email "admin@example.com"
    # git config --global user.name "root"

3. Copy the lab files into the ``mywebapp`` repository::

    # cp ~/gitlab/lab/* .

This folder contains:
   - **.gitlab-ci.yml**: pipeline definition
   - **hosts**: ansible host file with BIG-IQ access information
   - **bigiq_as3_deploy.yml**: ansible playbook to deploy the AS3 application services
   - **as3/my_http_app_service1.json**: AS3 declaration defining HTTP application service load balancer

4. Add and commit the new files to the ``mywebapp`` repository::

    # git status
    # git add .
    # git status
    # git commit -m "Add .gitlab-ci.yml, Ansible playbook, host file and AS3 declaration"
    # git status

5. Push the changes to gitlab::

    # git push origin master

6. Back in gitlab, navigate under jobs and click on the running jobs, display output.

7. Login on **BIG-IQ** as **david**, go to Applications tab and check the application is displayed and analytics are showing. 


Infrastructure as code: add a new pool member to the AS3 app service through GitLab
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Now, let's add a new pool member to our HTTP application service. Edit the file ``as3/my_http_app_service1.json``::

    # vi as3/my_http_app_service1.json

Add the pool member ``10.1.20.111`` as showing below:

.. code-block:: yaml
   :linenos: 6

   "members": [
   {
      "servicePort": 80,
      "serverAddresses": [
      "10.1.20.110",
      "10.1.20.111"
      ],
      "shareNodes": true
   }

3. Commit and push the changes::

    # git commit -m "Add new pool member 10.1.20.111"
    # git status
    # git push origin master

4. Back in gitlab, navigate under jobs and click on the running jobs, display output.

5. Login on **BIG-IQ** as **david**, go to Applications tab and check the new pool member has been added.



.. |lab-12-1| image:: ../pictures/module2/lab-12-1.png
   :scale: 40%

.. |lab-12-2| image:: ../pictures/module2/lab-12-2.png
   :scale: 40%

.. |lab-12-3| image:: ../pictures/module2/lab-12-3.png
   :scale: 40%

.. |lab-12-4| image:: ../pictures/module2/lab-12-4.png
   :scale: 40%

.. |lab-12-5| image:: ../pictures/module2/lab-12-5.png
   :scale: 40%

.. |lab-12-6| image:: ../pictures/module2/lab-12-6.png
   :scale: 40%

.. |lab-12-7| image:: ../pictures/module2/lab-12-7.png
   :scale: 40%

.. |lab-12-8| image:: ../pictures/module2/lab-12-8.png
   :scale: 40%

.. |lab-12-9| image:: ../pictures/module2/lab-12-9.png
   :scale: 40%

.. |lab-12-10| image:: ../pictures/module2/lab-12-10.png
   :scale: 40%