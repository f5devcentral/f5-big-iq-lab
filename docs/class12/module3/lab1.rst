Lab 3.1: SSLo configuration through declarative API
---------------------------------------------------

.. note:: Estimated time to complete: **20 minutes**

Workflow
^^^^^^^^

    #. In this lab, **Larry** will provide to **David** with a new JSON blob so that **David** can deploy a SSLo Outbound service with one Declarative API call.


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

    #. You should see on the right frame, the response from BIG-IQ. Now, you have a token, and you can send REST calls to BIG-IQ.
    #. It is time to send our ``declarative API call`` that will configure our required configuration. 
    #. The JSON blob (the declarative call) is below. You can notice the different sections (Topology, SSL_Settings, Security Policy, Service_Chain, Service)

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

    #. Click on ``Send Request`` and check the right frame of the screen.
    
            .. image:: ../pictures/module3/send_decl_config.png
               :align: center
    
    #. Now, let's check the status. To do so, we will use another REST call.
    #. Scroll down on the right side and copy the ``access-workflow ID``. This ID is the last string in ``selflink`` attribut. In this example the ID is ``a8d44084-0ace-4cd9-99d0-c9ba789ef128``. You might need to click on the link and then copy it from the URL in the new tab to get it copied.
        
        .. image:: ../pictures/module3/access_workflow_id.png
           :align: center

    #. On the left side scroll down to the section "Check status" and replace the ID by the one you just copied.
    #. For example:
    
    GET https://{{bigiq}}/mgmt/cm/sslo/tasks/api/a8d44084-0ace-4cd9-99d0-c9ba789ef128 HTTP/1.1
           
    #. Now click on ``Send Request``
    
    #. You should see a ``200 OK``, and ``status : Finshed``

        .. image:: ../pictures/module3/response_check_status.png
           :align: center
           :scale: 60%

    #. Connect to BIG-IQ GUI as ``david`` and double check under ``SSL Orchestrator`` that the ``Topologies: sslo_NewTopology_Dec `` got created.
    
    .. image:: ../pictures/module3/BIG-IQ_SSLO_Topo_view.png
           :align: center
           :scale: 60%
           
.. note:: Congrats, with one call, you deployed a new SSLo Topology including SSL_Settings, Security Policy, Service_Chain and Service
