Lab 8.1: VE creation
--------------------
``Ça arrive bientôt זה בקרוב Viene pronto すぐに来る Sta arrivando presto قادم قريبا Coming soon 即將到來``

To create the VPN between UDF and AWS and create the cloud provider and environement for DO

SSH Ubuntu host in UDF
go To ~/lab/f5-aws-vpn-ssg
run ./000-RUN_ALL.sh ve

=> SHOULD NOT NEED TO TOUCH

We will need to highlight the difference between cloud env for SSG and for DO (different required fields)

Then we should show creation of the VE via
- the UI step by step
- via the API
=> I started to write playbooks in folder lab/f5-ansible-bigiq-ve-creation-do-demo