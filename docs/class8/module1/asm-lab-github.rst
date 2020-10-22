.. TITLE: Deploy a WAF with BIG-IQ and AS3 using an ASM policy on GitHub

.. note:: Estimated time to complete: **20 minutes**

.. include:: /accesslab.rst

Workflow
^^^^^^^^

1. **Larry** upload the ASM policy in transparent mode on GitHub.
2. **David** creates the AS3 template and reference ASM policy URL created by **Larry** using URL.
3. **David** assigns the AS3 template to Paula.
4. **Paula** creates her application service using the template given by **david**.
5. **Paula** test her application and change the policy to blocking mode from her application dashboard.

Prerequisites
^^^^^^^^^^^^^

1. First make sure your device has ASM module discovered and imported 
for **SEA-vBIGIP01.termmarc.com** under Devices > BIG-IP DEVICES.

2. Check if the **Web Application Security** service is Active 
under System > BIOG-IQ DATA COLLECTION > BIG-IQ Data Collection Devices.

ASM Policy creation (Larry)
^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this lab, we are going to use the ASM templates available on the `F5 devcentral GitHub repository`_. 

.. _F5 devcentral GitHub repository: https://github.com/f5devcentral/f5-asm-policy-templates/tree/master/owasp_ready_template

We are going to use the WAF policy template called ``owasp-auto-tune-v1.1.xml``.

AS3 WAF template creation (David)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Login as **david** and Go to the Applications tab > Applications Templates and 
   select ``AS3-F5-HTTPS-WAF-external-url-lb-template-big-iq-default-<version>``.

.. image:: ../pictures/asm-as3/lab-7-1.png
  :scale: 40%
  :align: center

2. Select the ``WAF_Policy`` AS3 class. Look at the URL of the WAF policy stored on GitHub.

.. image:: ../pictures/asm-as3/lab-7-2.png
  :scale: 40%
  :align: center


2. Before **paula** can use this AS3 template, **david** needs to update her role.
   Use the previous steps in `Lab 3.2`_ to make sure AS3 Template ``AS3-F5-HTTPS-WAF-external-url-lb-template-big-iq-default`` 
   is assigned to ``Application Creator VMware`` custom role used by **Paula**.

.. _Lab 3.2: ./lab2.html

.. image:: ../pictures/asm-as3/lab-7-3.png
  :scale: 40%
  :align: center

.. image:: ../pictures/asm-as3/lab-7-4.png
  :scale: 40%
  :align: center


AS3 WAF application service deployment (Paula)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now let's create the WAF application service using AS3 & BIG-IQ.

1. Login as **paula** and select previously created ``LAB_module3`` Application and click **Create**.
  
2. Click **Create** to create an Application Service:

.. image:: ../pictures/asm-as3/lab-7-5.png
  :scale: 40%
  :align: center

+---------------------------------------------------------------------------------------------+
| Application properties:                                                                     |
+---------------------------------------------------------------------------------------------+
| * Grouping = ``New Application`` or ``Part of an Existing Application``                     |
| * Application Name = ``LAB_module3``                                                        |
+---------------------------------------------------------------------------------------------+
| Select an Application Service Template:                                                     |
+---------------------------------------------------------------------------------------------+
| * Template Type = Select ``AS3-F5-HTTPS-WAF-external-url-lb-template-big-iq-default [AS3]`` |
+---------------------------------------------------------------------------------------------+
| General Properties:                                                                         |
+---------------------------------------------------------------------------------------------+
| * Application Service Name = ``https_waf_url_app_service``                                  |
| * Target = ``SEA-vBIGIP01.termmarc.com``                                                    |
| * Tenant = ``tenant4``                                                                      |
+---------------------------------------------------------------------------------------------+
| Pool                                                                                        |
+---------------------------------------------------------------------------------------------+
| * Members: ``10.1.20.123``                                                                  |
+---------------------------------------------------------------------------------------------+
| TLS_Server. Keep default.                                                                   |
+---------------------------------------------------------------------------------------------+
| WAF_Policy. Keep default.                                                                   |
+---------------------------------------------------------------------------------------------+
| Certificate                                                                                 |
+---------------------------------------------------------------------------------------------+
| * privateKey: *use private key exampke below*                                               |
| * certificate: *use certificsate example below*                                             |
+---------------------------------------------------------------------------------------------+
| Service_HTTPS                                                                               |
+---------------------------------------------------------------------------------------------+
| * Virtual addresses: ``10.1.10.126``                                                        |
+---------------------------------------------------------------------------------------------+
| Analytics_Profile. Keep default.                                                            |
+---------------------------------------------------------------------------------------------+
| Security_Log_Profile. Keep default.                                                         |
+---------------------------------------------------------------------------------------------+

.. code-block:: bash

    -----BEGIN PRIVATE KEY-----
    MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDAQw08BODtXPeOoichV/aOc6L/38dgivzFliBTRgccUSKq5Dqdh9fibB7NnrOj0YmibuAeJDcU3Ld835Fq1q1mYGa7K8n7P+5nqlsqay4ks8tPz2iU70nEy1vhrzegcPPd/qtxzaPwrBOviVQNzjnaMsXhlDnk7Xuza1gyDhdbYbkOpQbOnVQqIKVoO+k3bdlU6WeoNWkiWdW8nWbPXYDMU+fLzEPWWEgu/vzIyW2KZ1paHIItwWibQNuWhG9iajCMYseotMBnjSMjdhR3Df0sSpNeB8MXcOc6BkIh1Gmi4P1xVkGhCuhelVV9Ybux/MoupZoAQeGNuF0rmX+neZPvAgMBAAECggEAHm3eV9v7z4WRxtjiMZRO+Q/TQgUkdKK6y/jtR9DDClfLEVoK7ujTocnz/B48l1ZwHq3Gue6IazxdrB1kUhEFI7lpOQF+t83QCUc8o5OQG437RTfx+PSAa+21rpwBRVrrNfz7HIlsA4jwmq01CPRVUrQLfp7rpNBzbhu0u0Ngrf0ccOwXZkEUVvZ55WaPY1YADI9PBExQ2k04LvHJjoz/tJH3nsQLA/+90UXqy8ctUSMJ8Ko3crxJhnIO91BtCugkgS+U+pTEnvdAebE4pd7J5e6qqEyCu9F3DC5R6hH+K8bAj76VGwjxOr9a90o/js92HoCVAlQMHnW06Uk2RdIRmQKBgQD0uQPlA2PLBysWA+IQvd8oBfZuXWQjUZPBU9MK5k7bfuRbNeCA2kbTt1MVf15lv7vcwrwAbYo+Ur+L9CVL3lA8d/lQkz51r1ISChTPUiAMyU+CDDnXjQ1Gik/nC399AeluxS62Tur8hGPAb4rkVEyU60hPFVZTjmv13n81EjUoNwKBgQDJHyiPIgbwI+OoZYMUcGQrsr+yp1MdJrjpuFloc7+sdUpsvelyc146h3+TSAlhDce2BMH68kMUWUYHxHIooQjtDMu9S9b8VAF52F3E9osyjMzsywTri3hgBPy69j/Kr623gbZpbm6lYmdxRp/FKZyWtAbPts45GH1GPdv+9fUmCQKBgQCX7CfDy1fvWXLhBuYXuJfJs/HpT+bzmhgdA5nXgWRhFSRUj1zhASDJHFzi0qBakC3i/a1Soq4YxKwPCTECKXAsKdrHr7Etw/oyIroKfpRQ+8R1GnvqGbGtIf46k8PAaihtUNIP8Wwl+VYnx9c0qjSkmm/YUIm384mIKGlWHAiN/wKBgDV5bF5KLNASqsguXWDE1U1tFF0a8hVRI185HcSQ6gifku9Au14r4ITtW/U79QpyEISL1Uu0uDMj3WPZToUQ8/+bJFyrWnjymQXdimkBKFeDakUXYbKC/bmB+fR33tQ0S5r8CRUVQKQGevx6S6avfqvvJ9R4hXJW2ZAgiGrM2KaJAoGAPXuy4KHRmeeBZj8AT/shQ0VrDWIMNYDrhx0T6q9hVMahBS0SJaKDlQn6cSF7TX5N9PFAbwzcrvRKKfNjQVSZpQdR4l42f+N/5q0c1wihf43k9FgeYQ8jHGJ05uJnh3nj/O57FKgjlZ4FZVQdR8ieHN+rT4sHWj36a/FLHa6p1oo=
    -----END PRIVATE KEY-----

.. code-block:: bash

    -----BEGIN CERTIFICATE-----
    MIID7TCCAtWgAwIBAgIJAJH4sMVzl1dMMA0GCSqGSIb3DQEBCwUAMIGMMQswCQYDVQQGEwJVUzETMBEGA1UECAwKV2FzaGluZ3RvbjEQMA4GA1UEBwwHU2VhdHRsZTELMAkGA1UECgwCRjUxDTALBgNVBAsMBFRlc3QxEzARBgNVBAMMCnRscy1zZXJ2ZXIxJTAjBgkqhkiG9w0BCQEWFnNvbWVib2R5QHNvbWV3aGVyZS5jb20wHhcNMTgwMjI4MTkwNzMyWhcNMjgwMjI2MTkwNzMyWjCBjDELMAkGA1UEBhMCVVMxEzARBgNVBAgMCldhc2hpbmd0b24xEDAOBgNVBAcMB1NlYXR0bGUxCzAJBgNVBAoMAkY1MQ0wCwYDVQQLDARUZXN0MRMwEQYDVQQDDAp0bHMtc2VydmVyMSUwIwYJKoZIhvcNAQkBFhZzb21lYm9keUBzb21ld2hlcmUuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwEMNPATg7Vz3jqInIVf2jnOi/9/HYIr8xZYgU0YHHFEiquQ6nYfX4mwezZ6zo9GJom7gHiQ3FNy3fN+RatatZmBmuyvJ+z/uZ6pbKmsuJLPLT89olO9JxMtb4a83oHDz3f6rcc2j8KwTr4lUDc452jLF4ZQ55O17s2tYMg4XW2G5DqUGzp1UKiClaDvpN23ZVOlnqDVpIlnVvJ1mz12AzFPny8xD1lhILv78yMltimdaWhyCLcFom0DbloRvYmowjGLHqLTAZ40jI3YUdw39LEqTXgfDF3DnOgZCIdRpouD9cVZBoQroXpVVfWG7sfzKLqWaAEHhjbhdK5l/p3mT7wIDAQABo1AwTjAdBgNVHQ4EFgQUBlCKIZ0+9DQ4ylW86qsyXoW8KjkwHwYDVR0jBBgwFoAUBlCKIZ0+9DQ4ylW86qsyXoW8KjkwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAuiE5MocznYDc+JHvEgSaiK9fyRBl/bitKTkiOtxWjEFpF5nH6QddV0pqQziXLb6iSbTBwlDJr9Bwzng8moOYbsD7hP2/mCKJj8o/lsRaPAk+abekWXRqYFNucct/ipBG3s+N2PH+MEpy3ioPH1OBuam6UomjE+mqoP09FrQha1hHEbabt4nN11l8fM5GW+0zRU0SwLFvnR58zUSlTMwczSPA0eUrhEU4AGPD/KN8d1fYnCcWqPF5ePcU11k7SNFl5PZQsgXv9cOc2Vq+qc/NmDBO0rQyKEAPDxbM8CK212G1M+ENTqmuePnr+mNope3AhEsqfH8IOPEoT7fIwmpqLw==
    -----END CERTIFICATE-----

3. Click **Create**.

4. Check the application service ``https_waf_url_app_service`` has been created under Application ``LAB_module3``.

.. image:: ../pictures/asm-as3/lab-7-6.png
  :scale: 40%
  :align: center

.. image:: ../pictures/asm-as3/lab-7-7.png
  :scale: 40%
  :align: center

5. What is the enforced Protection Mode?

.. image:: ../pictures/asm-as3/lab-7-8.png
  :scale: 40%
  :align: center

Test and enforcement mode update (Paula)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. From the lab environment, launch a remote desktop session to have access to the Ubuntu Desktop. 

2. Open Chrome and navigate to the following URL: ``https://10.1.10.126`` which open the web application protected by the WAF policy.

3. We will now install the F5 WAF tester tool. Connect via ``SSH`` to the *Ubuntu Lamp Server* and execute:

.. code-block:: bash

   f5student@ip-10-1-1-5:~$ sudo pip install git+https://github.com/f5devcentral/f5-waf-tester.git

   f5student@ip-10-1-1-5:~$ sudo f5-waf-tester --init
   [BIG-IP] Host []: 10.1.1.7   
   [BIG-IP] Username []: admin
   [BIG-IP] Password []: 
   ASM Policy Name []: /tenant4/https_waf_url_app_service/WAF_Policy
   Virtual Server URL []: https://10.1.10.126
   Blocking Regular Expression Pattern [<br>Your support ID is: (?P<id>\d+)<br>]: 
   Number OF Threads [25]: 
   [Filters] Test IDs to include (Separated by ',') []: 
   [Filters] Test Systems to include (Separated by ',') []: 
   [Filters] Test Attack Types to include (Separated by ',') []: 
   [Filters] Test IDs to exclude (Separated by ',') []: 
   [Filters] Test Systems to exclude (Separated by ',') []: 
   [Filters] Test Attack Types to exclude (Separated by ',') []: 

4. Now, let's launch an attack on this application service while the policy is in transparent mode. 

On the *Ubuntu Lamp Server*, run:

.. code-block:: bash
   :emphasize-lines: 38,39

   f5student@ip-10-1-1-5:~$ sudo f5-waf-tester
   09-06-20 02:32:27 INFO Test 100000002/parameter failed
   09-06-20 02:32:27 INFO Test 100000002/url failed
   09-06-20 02:32:27 INFO Test 100000001/parameter failed
   09-06-20 02:32:27 INFO Test 100000001/header failed
   09-06-20 02:32:27 INFO Test 100000004/parameter failed
   09-06-20 02:32:27 INFO Test 100000006/parameter failed
   09-06-20 02:32:27 INFO Test 100000004/header failed
   09-06-20 02:32:27 INFO Test 100000007/url failed
   09-06-20 02:32:27 INFO Test 100000003/header failed
   09-06-20 02:32:27 INFO Test 100000005/header failed
   09-06-20 02:32:27 INFO Test 100000005/parameter failed
   09-06-20 02:32:27 INFO Test 100000002/header failed
   09-06-20 02:32:27 INFO Test 100000001/url failed
   09-06-20 02:32:27 INFO Test 100000006/header failed
   09-06-20 02:32:27 INFO Test 100000009/parameter failed
   09-06-20 02:32:27 INFO Test 100000010/request failed
   ...
      "100000024": {
         "CVE": "", 
         "attack_type": "Server Side Request Forgery", 
         "name": "SSRF attempt - Local network IP range 10.x.x.x", 
         "results": {
         "request": {
            "expected_result": {
               "type": "signature", 
               "value": "200020201"
            }, 
            "pass": false, 
            "reason": "Unknown, Maybe ASM Policy is not in blocking mode", 
            "support_id": ""
         }
         }, 
         "system": "All systems"
      }
   }, 
   "summary": {
      "fail": 48, 
      "pass": 0
   }

5. Back to the BIG-IQ and logged in as **paula**, let's look at the attack on the BIG-IQ Dashboard.

Under **F5 Services**, Security > Analytics > All Transactions

.. image:: ../pictures/asm-as3/lab-7-9.png
  :scale: 40%
  :align: center

Violations:

.. image:: ../pictures/asm-as3/lab-7-10.png
  :scale: 40%
  :align: center

6. Now, Paula change the WAF policy mode from Transparent to Blocking in order to apply L7 protection to her application.

Under **F5 Services**, Configuration, update Enforcement Mode to **Blocking**.

.. image:: ../pictures/asm-as3/lab-7-11.png
  :scale: 40%
  :align: center

Notice the shield changing color in the BIG-IQ dashboard.

.. image:: ../pictures/asm-as3/lab-7-12.png
  :scale: 40%
  :align: center

Wait for the current major and critical alerts to clear before moving to the next step.

.. image:: ../pictures/asm-as3/lab-7-13.png
  :scale: 40%
  :align: center

7. Back on the *Ubuntu Lamp Server*, let's launch a second attack on this application service while the policy is in blocking mode. 

.. code-block:: bash
   :emphasize-lines: 35,36

   f5student@ip-10-1-1-5:~$ sudo f5-waf-tester
   09-06-20 02:39:44 INFO Test 100000002/parameter pass
   09-06-20 02:39:44 INFO Test 100000003/parameter pass
   09-06-20 02:39:44 INFO Test 100000005/url pass
   09-06-20 02:39:44 INFO Test 100000004/header pass
   09-06-20 02:39:44 INFO Test 100000001/url pass
   09-06-20 02:39:44 INFO Test 100000005/parameter pass
   09-06-20 02:39:44 INFO Test 100000006/parameter pass
   09-06-20 02:39:44 INFO Test 100000006/header pass
   09-06-20 02:39:44 INFO Test 100000004/url pass
   09-06-20 02:39:44 INFO Test 100000001/header pass
   09-06-20 02:39:44 INFO Test 100000001/parameter pass
   09-06-20 02:39:44 INFO Test 100000003/header pass
   09-06-20 02:39:44 INFO Test 100000002/url pass
   ...
      "100000024": {
         "CVE": "", 
         "attack_type": "Server Side Request Forgery", 
         "name": "SSRF attempt - Local network IP range 10.x.x.x", 
         "results": {
         "request": {
            "expected_result": {
               "type": "signature", 
               "value": "200020201"
            }, 
            "pass": false, 
            "reason": "Attack Signature is not in the ASM Policy", 
            "support_id": ""
         }
         }, 
         "system": "All systems"
      }
   }, 
   "summary": {
      "fail": 3, 
      "pass": 45
   }


8. Notice after few seconds the BIG-IQ dashboard reporting the attack.

.. image:: ../pictures/asm-as3/lab-7-14.png
  :scale: 40%
  :align: center

Expend the dimensions and filter on **Blocked** attack to see attacks being blocked by the WAF policy.

.. image:: ../pictures/asm-as3/lab-7-15.png
  :scale: 40%
  :align: center

