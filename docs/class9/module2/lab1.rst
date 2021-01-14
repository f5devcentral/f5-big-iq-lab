Lab 2.1: SAML SP Application configuration through declarative API
------------------------------------------------------------------

.. note:: Estimated time to complete: **20 minutes**

Workflow
^^^^^^^^

    #. In this lab, **Larry** will provide to **David** with a new JSON blob so that **David** can deploy an application protected by APM with one Declarative API called 
    #. Compared to the previous lab with AS3, this new Declarative API blob will include the policy creation and the application creation. In the previous lab, AS3 "refered" to an existine APM oilicy



Application creation with one Declarative API call
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#. Connect to ``Visual Studio Code`` by clicking on the link under ``Access`` menu on ``Ubuntu 19.10`` machine.

    .. image:: ../pictures/module2/link_vsc.png
       :align: center

#. VSC will open, and on the left menu, click on file ``postman_class9.rest`` in ``project`` directory

     .. image:: ../pictures/module2/link_postman_file.png
       :align: center

#. Now, on the right frame, you can see the different ``Postman`` calls. We will run them, one by one. It is important to understand each of them

    #. The ``first call`` is to authenticate against the BIG-IQ, and get a token. Use the first call (line #9). Click on ``Send Request``

        .. image:: ../pictures/module2/postman_auth.png
           :align: center

    #. You should see on the right frame, the response from BIG-IQ. Now, you have a token, and you send REST calls to BIG-IQ.
    #. It is time to send our ``declarative API call`` that will configure our new VS + APM policy as SAML SP.
    #. The JSON blob (the declarative call) is below. You can notice the different sections (SAML SP, SAML IDP connector, VS, SSO, EndPoint check)

        .. code :: javascript

            {
                "name": "workflow_saml_2",
                "type": "samlSP",
                "accessDeviceGroup": "boston",
                "configurations": {
                    "samlSPService": {
                        "entityId": "https://www.testsaml.com",
                        "idpConnectors": [
                            {
                                "connector": {
                                    "entityId": "https://www.testidp.com",
                                    "ssoUri": "https://www.testidp.com/sso"
                                }
                            }
                        ],
                        "attributeConsumingServices": [
                            {
                                "service": {
                                    "serviceName": "wf_service4",
                                    "isDefault": true,
                                    "attributes": [
                                        {
                                            "attributeName": "wf_name4"
                                        }
                                    ]
                                }
                            }
                        ],
                        "authContextClassList": {
                            "classes": [
                                {
                                    "value": "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
                                }
                            ]
                        }
                    },
                    "accessProfile": {},
                    "singleSignOn": {
                        "type": "httpHeaders",
                        "httpHeaders": [
                            {
                                "headerName": "Authorization",
                                "headerValue": "%{session.saml.last.identity}"
                            },
                            {
                                "headerName": "Authorization2",
                                "headerValue": "%{session.saml.last.identity2}"
                            }
                        ]
                    },
                    "endpointCheck": {
                        "clientOS": {
                            "windows": {
                                "windows7": true,
                                "windows10": true,
                                "windows8_1": true,
                                "antivirus": {},
                                "firewall": {},
                                "machineCertAuth": {}
                            },
                            "windowsRT": {
                                "antivirus": {},
                                "firewall": {}
                            },
                            "linux": {
                                "antivirus": {
                                    "dbAge": 102,
                                    "lastScan": 102
                                },
                                "firewall": {}
                            },
                            "macOS": {
                                "antivirus": {
                                    "dbAge": 103,
                                    "lastScan": 103
                                }
                            },
                            "iOS": {},
                            "android": {},
                            "chromeOS": {
                                "antivirus": {
                                    "dbAge": 104,
                                    "lastScan": 104
                                },
                                "firewall": {}
                            }
                        }
                    }
                }
            }

    #. Click on ``Send Request`` and check the right frame of the screen. You should see a ``2O2 Accepted``
    #. Scroll down and copy the ``access-workflow ID``. This ID is the last string in ``selflink`` attribut. In my example belown the ID is ``6fe131ef-4edb-4977-9073-fdea042b47ec``
        
        .. image:: ../pictures/module2/workflow_id.png
           :align: center

    #. Now, let's check if the workflow passed. To do so, we will use another REST call. On the left frame, at the top, in the ``My Variables`` section, change the value of ``@workflow_id`` by the copied ID.
        
        .. image:: ../pictures/module2/my_variables.png
           :align: center

    #. Scroll down, and use the last REST call ``Check status of the deployment``. Click ``Send Request``
    #. You should see a ``200 OK``, and ``status : finshed``

        .. image:: ../pictures/module2/workflow_status.png
           :align: center

    #. Connect to BIG-IQ GUI as ``david`` and check your ``APM policy`` and ``Virtual Server`` are created.
    #. The last step -> Deploy your configuration.

.. note:: Congrats, with one call, you deployed a new Service protected by APM as a SAML Service Provider. You can now replicate the same call for every new app by changing the name of the SAML SP object, and the VS config.
