Lab 3.8: Deploy a WAF with BIG-IQ and AS3 using an ASM policy on BIG-IQ
-----------------------------------------------------------------------
``Ça arrive bientôt זה בקרוב Viene pronto すぐに来る Sta arrivando presto قادم قريبا Coming soon 即將到來``

Are you interested to see a lab on this topic? `Open an issue on GitHub`_

.. _Open an issue on GitHub: https://github.com/f5devcentral/f5-big-iq-lab/issues

Workflow
^^^^^^^^

1. **Larry** creates the ASM policy template in transparent mode on the BIG-IQ.
2. **David** creates the AS3 template and reference ASM policy template created by **Larry** in the template using url.
3. **David** assigns the AS3 template to Paula.
4. **Paula** creates her application service using the template given by **david**.
5. After **Paula** does the necessary testing of her application, she reaches to Larry.
6. **Larry** reviews the ASM learning and deploy the ASM policy changes on the BIG-IP(s).
7. **Paula** change the policy to blocking mode from her application dashboard.

Prerequisites
^^^^^^^^^^^^^

1. First make sure your device has ASM module discovered and imported 
for **SEA-vBIGIP01.termmarc.com** under Devices > BIG-IP DEVICES.

2. Check if the **Web Application Security** service is Active 
under System > BIOG-IQ DATA COLLECTION > BIG-IQ Data Collection Devices.

ASM Policy template creation (Larry)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Ça arrive bientôt זה בקרוב Viene pronto すぐに来る Sta arrivando presto قادم قريبا Coming soon 即將到來``

Are you interested to see a lab on this topic? `Open an issue on GitHub`_

.. _Open an issue on GitHub: https://github.com/f5devcentral/f5-big-iq-lab/issues