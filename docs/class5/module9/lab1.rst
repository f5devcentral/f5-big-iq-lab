Lab 9.1: VE creation
--------------------
``Ça arrive bientôt זה בקרוב Viene pronto すぐに来る Sta arrivando presto قادم قريبا Coming soon 即將到來``

To create the VPN between UDF and Azyre and create the cloud provider and environement for DO

SSH Ubuntu host in UDF
go To go To ~/lab/f5-azure-vpn-ssg
run ./000-RUN_ALL.sh ve

=> SHOULD NOT NEED TO TOUCH

The script uses user's Azure account so the config.yml needs to be filled (look at Azure SSG lab in class2)

We will need to highlight the difference between cloud env for SSG and for DO (different required fields)

Then we should show creation of the VE via
- the UI step by step
- via the API
=> I started to write playbooks in folder lab/f5-ansible-bigiq-ve-creation-do-demo

