Lab 3.1: SSLo configuration through declarative API
---------------------------------------------------

.. note:: Estimated time to complete: **20 minutes**

Workflow
^^^^^^^^

    #. In this lab, **Larry** will provide to **David** with a new JSON blob so that **David** can deploy an application protected by APM with one Declarative API called 
    #. Compared to the previous lab with AS3, this new Declarative API blob will include the policy creation and the application creation. In the previous lab, AS3 "refered" to an existine APM oilicy



Service creation with one Declarative API call
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

#. Connect to ``Visual Studio Code`` by clicking on the link under ``Access`` menu on ``Ubuntu`` machine (follow |location_link_vscode_restclient|).

.. |location_link_vscode_restclient| raw:: html

   <a href="/training/community/big-iq-cloud-edition/html/vscode_restclient.html" target="_blank">instructions</a>

#. VSC will open, and on the left menu, click on file ``postman_SSLo.rest`` in ``project`` directory

     .. image:: ../pictures/module3/click_postman_SSLo.png
       :align: center
       :scale: 60%

#. Now, on the right frame, you can see the different ``Postman`` calls. We will run them, one by one. It is important to understand each of them

    #. The ``first call`` is to authenticate against the BIG-IQ, and get a token. Use the first call (line #9). Click on ``Send Request``

        .. image:: ../pictures/module3/authenticate.png
           :align: center

    #. You should see on the right frame, the response from BIG-IQ. Now, you have a token, and you send REST calls to BIG-IQ.
    #. It is time to send our ``declarative API call`` that will configure our new VS + APM policy as SAML SP.
    #. The JSON blob (the declarative call) is below. You can notice the different sections (SAML SP, SAML IDP connector, VS, SSO, EndPoint check)

        .. code :: javascript

  {
    "template": {
        "TOPOLOGY": {
            "name": "sslo_NewTopology_Dec",
            "ingressNetwork": {
                "vlans": [
                    {
                        "name": "/Common/VLAN_TAP"
                    }
                ]
            },
            "type": "topology_l3_outbound",
            "sslSetting": "ssloT_NewSsl_Dec",
            "securityPolicy": "ssloP_NewPolicy_Dec"
        },
        "SSL_SETTINGS": {
            "name": "ssloT_NewSsl_Dec"
        },
        "SECURITY_POLICY": {
            "name": "ssloP_NewPolicy_Dec",
            "rules": [
                {
                    "mode": "edit",
                    "name": "Pinners_Rule",
                    "action": "allow",
                    "operation": "AND",
                    "conditions": [
                        {
                            "type": "SNI Category Lookup",
                            "options": {
                                "category": [
                                    "Pinners"
                                ]
                            }
                        },
                        {
                            "type": "SSL Check",
                            "options": {
                                "ssl": true
                            }
                        }
                    ],
                    "actionOptions": {
                        "ssl": "bypass",
                        "serviceChain": "ssloSC_NewServiceChain_Dec"
                    }
                },
                {
                    "mode": "edit",
                    "name": "All Traffic",
                    "action": "allow",
                    "isDefault": true,
                    "operation": "AND",
                    "actionOptions": {
                        "ssl": "intercept"
                    }
                }
            ]
        },
        "SERVICE_CHAIN": {
            "ssloSC_NewServiceChain_Declarative": {
                "name": "ssloSC_NewServiceChain_Dec",
                "orderedServiceList": [
                    {
                        "name":"ssloS_ICAP_Dec"
                    }
                ]
            }
        },
        "SERVICE": {
            "ssloS_ICAP_Declarative": {
                "name": "ssloS_ICAP_Dec",
                "customService": {
                    "name": "ssloS_ICAP_Dec",
                    "serviceType": "icap",
                    "loadBalancing": {
                        "devices": [
                            {
                                "ip": "3.3.3.3",
                                "port": "1344"
                            }
                        ]
                    }
                }
            }
        }
    },
    "targetList": [
        {
            "type": "DEVICE",
            "name": "SEA-vBIGIP01.termmarc.com"
        }
    ]
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
           :scale: 60%

    #. Connect to BIG-IQ GUI as ``david`` and check your ``APM policy`` and ``Virtual Server`` are created.
    #. The last step -> Deploy your configuration.

.. note:: Congrats, with one call, you deployed a new Service protected by APM as a SAML Service Provider. You can now replicate the same call for every new app by changing the name of the SAML SP object, and the VS config.
