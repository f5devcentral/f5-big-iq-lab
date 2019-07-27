Module 2: Configure DoS Profile Settings
========================================

Goal:

In this lab, we will configure both the Device DoS profile along with creating and deploying a DoS Profile to a Virtual Server using BIG-IQ and deploying to the BIG-IP. We also will use a new feature in BIG-IQ to help manage Device DoS Profiles. 

**Tasks:**

1. Modify and Deploy Device DoS Profile

2. Create, configure, and deploy DoS Profile to a Virtual Server

3. Manging Device DoS Profiles

As a pre-requisite for Lab 3, the TMOS version of all BIG-IPs must be the same. To facilitate this, the SJC BIG-IP must be upgraded to the same version as the BOS BIG-IP cluster. 

1. Under *Devices* > *Software Management* > *Software Installations* create a New Managed Device Install task
2. Create a task name, the 13.1.1 TMOS image, and select the SJC BIG-IP as shown in the image below to install to a new volume 

.. image:: ../pictures/module2/software-upgrade.png
  :align: center
  :scale: 50%


3. Click *Run* to start the task: saving and closing does not start the task :) 
4. With this task running it can be checked periodically if desired but should be done before needing it in lab 2

.. toctree::
   :maxdepth: 1
   :glob:

   lab*

