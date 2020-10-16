Lab 6.5: Disable/Enable Pool Member of a Legacy Application Service via the API
-------------------------------------------------------------------------------

.. note:: Estimated time to complete: **15 minutes**

In this lab, we are going to disable a pool member part of a legacy application service managed by BIG-IQ.

We are going to use the following BIG-IQ API:
    - `Applications`_: API used to get the details of the legacy application service including the virtual server reference
    - `Pool and Pool Members Management`_: API used to get the details of Pool objects linked to the virtual server
    - `LTM/ADC Self-Service Task (enable/disable pool member)`_: API used to get the details of the pool member(s)/server(s)

.. Applications: https://clouddocs.f5.com/products/big-iq/mgmt-api/v7.1.0/ApiReferences/bigiq_public_api_ref/r_adc_config_set_state.html?highlight=configset
.. LTM/ADC Pool Member Management: https://clouddocs.f5.com/products/big-iq/mgmt-api/v7.1.0/ApiReferences/bigiq_public_api_ref/r_pool_member_management_60.html
.. LTM/ADC Self-Service Task (enable/disable pool member): https://clouddocs.f5.com/products/big-iq/mgmt-api/v7.1.0/ApiReferences/bigiq_public_api_ref/r_adc_self_service_60.html#get-mgmt-cm-adc-core-tasks-self-service

.. include:: /accesslab.rst

Open Chrome and Postman.

For Postman, click right and click on execute (wait ^2 minutes).

.. note:: If Postman does not open, open a terminal, type ``postman`` to open postman.

.. image:: ../../pictures/postman.png
    :align: center
    :scale: 60%

|

Using the declarative AS3 API, let's send the following BIG-IP configuration through BIG-IQ:

Using Postman select ``BIG-IQ Token (david)`` available in the Collections.
Press Send. This, will save the token value as _f5_token. If your token expires, obtain a new token by resending the ``BIG-IQ Token``

.. note:: The token timeout is set to 5 min. If you get the 401 authorization error, request a new token.

.. image:: ../pictures/module2/lab-1-1.png
    :align: center
    :scale: 60%

Find the Pool Member Reference
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Login to BIG-IQ as **paula** and navigate to **IT_apps > media.site42.example.com**. Select configuration and see the list of pool members related to this application service.

.. image:: ../pictures/module6/lab-5-1.png
  :scale: 40%
  :align: center

2. ``GET /mgmt/cm/global/config-sets?$filter=configSetName eq 'media.site42.example.com'``


.. code-block:: yaml
   :linenos:
   :emphasize-lines: 23

    {
        "totalItems": 1,
        "items": [
            {
                "id": "1d90f2b4-ab1e-3757-b4a2-0999055abf89",
                "kind": "cm:global:config-sets:configsetstate",
                "status": "CREATED",
                "selfLink": "https://localhost/mgmt/cm/global/config-sets/1d90f2b4-ab1e-3757-b4a2-0999055abf89",
                "generation": 82.0,
                "alertRuleName": "media.site42.example.com-health",
                "configSetName": "media.site42.example.com",
                "createDateTime": "2020-04-22T17:41:37.148Z",
                "lastConfigTime": "2020-04-22T17:41:37.148Z",
                "deviceReference": {
                    "link": "https://localhost/mgmt/shared/resolver/device-groups/cm-bigip-allBigIpDevices/devices/60bd5d38-dd9f-468b-a0f5-f3b78776b079"
                },
                "lastUpdateMicros": 1.602771513789654E15,
                "applicationReference": {
                    "link": "https://localhost/mgmt/cm/global/global-apps/c671ad43-9420-354e-942a-d8b9d865e08c"
                },
                "applicationServiceType": "HTTP",
                "classicConfigReference": {
                    "link": "https://localhost/mgmt/cm/global/classic-configs/918b8779-1d1a-32a8-a3a7-7126902986ba"
                }
            }
        ],
        "generation": 26,
        "kind": "cm:global:config-sets:configsetcollectionstate",
        "lastUpdateMicros": 1602771516243558,
        "selfLink": "https://localhost/mgmt/cm/global/config-sets"
    }

3. ``GET /mgmt/cm/global/classic-configs/918b8779-1d1a-32a8-a3a7-7126902986ba``

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 86

    {
        "id": "918b8779-1d1a-32a8-a3a7-7126902986ba",
        "kind": "cm:global:classic-configs:classicconfigstate",
        "name": "media.site42.example.com",
        "selfLink": "https://localhost/mgmt/cm/global/classic-configs/918b8779-1d1a-32a8-a3a7-7126902986ba",
        "machineId": "60bd5d38-dd9f-468b-a0f5-f3b78776b079",
        "generation": 1,
        "configObjects": [
            {
                "kind": "cm:adc-core:current-config:ltm:virtual:adcvirtualstate",
                "name": "vip142",
                "tags": [
                    {
                        "name": "BIGIQ_configSetName",
                        "value": "media.site42.example.com"
                    }
                ],
                "subPath": "app2",
                "partition": "legacy",
                "GSLBObject": false,
                "poolReference": "/legacy/app2/Pool",
                "destinationPort": 80,
                "destinationAddress": "10.1.10.142"
            },
            {
                "kind": "cm:adc-core:current-config:ltm:pool:adcpoolstate",
                "name": "Pool",
                "tags": [
                    {
                        "name": "BIGIQ_configSetName",
                        "value": "media.site42.example.com"
                    }
                ],
                "subPath": "app2",
                "partition": "legacy",
                "GSLBObject": false,
                "memberReference": [
                    "10.1.20.117:80",
                    "10.1.20.115:80",
                    "10.1.20.116:80"
                ]
            },
            {
                "kind": "cm:adc-core:current-config:ltm:pool:members:adcpoolmemberstate",
                "name": "10.1.20.117:80",
                "tags": [
                    {
                        "name": "BIGIQ_configSetName",
                        "value": "media.site42.example.com"
                    }
                ],
                "partition": "Common",
                "GSLBObject": false,
                "parentReference": "Pool"
            },
            {
                "kind": "cm:adc-core:current-config:ltm:pool:members:adcpoolmemberstate",
                "name": "10.1.20.115:80",
                "tags": [
                    {
                        "name": "BIGIQ_configSetName",
                        "value": "media.site42.example.com"
                    }
                ],
                "partition": "Common",
                "GSLBObject": false,
                "parentReference": "Pool"
            },
            {
                "kind": "cm:adc-core:current-config:ltm:pool:members:adcpoolmemberstate",
                "name": "10.1.20.116:80",
                "tags": [
                    {
                        "name": "BIGIQ_configSetName",
                        "value": "media.site42.example.com"
                    }
                ],
                "partition": "Common",
                "GSLBObject": false,
                "parentReference": "Pool"
            }
        ],
        "lastUpdateMicros": 1587577297085824,
        "currentConfigVirtualServerReferences": [
            {
                "link": "https://localhost/mgmt/cm/adc-core/current-config/ltm/virtual/c100e548-106f-3476-b0f5-dacda18ae2e7"
            }
        ]
    }

4. ``GET /mgmt/cm/adc-core/current-config/ltm/virtual/c100e548-106f-3476-b0f5-dacda18ae2e7``

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 25

    {
        "id": "c100e548-106f-3476-b0f5-dacda18ae2e7",
        "kind": "cm:adc-core:current-config:ltm:virtual:adcvirtualstate",
        "mask": "255.255.255.255",
        "name": "vip142",
        "nat64": "disabled",
        "state": "enabled",
        "mirror": "disabled",
        "subPath": "app2",
        "gtmScore": 0,
        "policies": [],
        "selfLink": "https://localhost/mgmt/cm/adc-core/current-config/ltm/virtual/c100e548-106f-3476-b0f5-dacda18ae2e7",
        "partition": "legacy",
        "rateLimit": "disabled",
        "generation": 11,
        "ipProtocol": "tcp",
        "sourcePort": "preserve",
        "autoLasthop": "default",
        "description": "app2",
        "vlansEnabled": "disabled",
        "addressStatus": "yes",
        "poolReference": {
            "id": "ef21f8dd-c75d-328d-8f21-8816a76d8c1b",
            "kind": "cm:adc-core:current-config:ltm:pool:adcpoolstate",
            "link": "https://localhost/mgmt/cm/adc-core/current-config/ltm/pool/ef21f8dd-c75d-328d-8f21-8816a76d8c1b",
            "name": "Pool",
            "subPath": "app2",
            "partition": "legacy"
        },
        "rateLimitMode": "object",
        "sourceAddress": "0.0.0.0/0",
        "translatePort": "enabled",
        "connectionLimit": 0,
        "destinationPort": "80",
        "deviceReference": {
            "id": "60bd5d38-dd9f-468b-a0f5-f3b78776b079",
            "kind": "shared:resolver:device-groups:restdeviceresolverdevicestate",
            "link": "https://localhost/mgmt/shared/resolver/device-groups/cm-adccore-allbigipDevices/devices/60bd5d38-dd9f-468b-a0f5-f3b78776b079",
            "name": "SEA-vBIGIP01.termmarc.com",
            "machineId": "60bd5d38-dd9f-468b-a0f5-f3b78776b079"
        },
        "lastUpdateMicros": 1602023309477006,
        "translateAddress": "enabled",
        "destinationAddress": "10.1.10.142",
        "sourceAddressTranslation": {
            "type": "automap"
        },
        "profilesCollectionReference": {
            "link": "https://localhost/mgmt/cm/adc-core/current-config/ltm/virtual/c100e548-106f-3476-b0f5-dacda18ae2e7/profiles",
            "isSubcollection": true
        },
        "defaultCookiePersistenceReference": {
            "id": "8195ebb4-1d65-3092-8166-ee6904604a99",
            "kind": "cm:adc-core:current-config:ltm:persistence:cookie:adcpersistencecookiestate",
            "link": "https://localhost/mgmt/cm/adc-core/current-config/ltm/persistence/cookie/8195ebb4-1d65-3092-8166-ee6904604a99",
            "name": "cookie",
            "partition": "Common"
        }
    }


5. ``GET /mgmt/cm/adc-core/current-config/ltm/pool/ef21f8dd-c75d-328d-8f21-8816a76d8c1b/members``

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 9, 59, 109

    {
        "items": [
            {
                "id": "6bd14736-285f-3338-850d-ff2378817fc6",
                "kind": "cm:adc-core:current-config:ltm:pool:members:adcpoolmemberstate",
                "name": "10.1.20.117:80",
                "port": 80,
                "ratio": 1,
                "selfLink": "https://localhost/mgmt/cm/adc-core/current-config/ltm/pool/ef21f8dd-c75d-328d-8f21-8816a76d8c1b/members/6bd14736-285f-3338-850d-ff2378817fc6",
                "partition": "Common",
                "rateLimit": "disabled",
                "generation": 14,
                "parentInfo": {
                    "id": "ef21f8dd-c75d-328d-8f21-8816a76d8c1b",
                    "name": "Pool",
                    "subPath": "app2",
                    "selfLink": "https://localhost/mgmt/cm/adc-core/current-config/ltm/pool/ef21f8dd-c75d-328d-8f21-8816a76d8c1b",
                    "partition": "legacy",
                    "generation": 0,
                    "deviceReference": {
                        "id": "60bd5d38-dd9f-468b-a0f5-f3b78776b079",
                        "kind": "shared:resolver:device-groups:restdeviceresolverdevicestate",
                        "link": "https://localhost/mgmt/shared/resolver/device-groups/cm-adccore-allbigipDevices/devices/60bd5d38-dd9f-468b-a0f5-f3b78776b079",
                        "name": "SEA-vBIGIP01.termmarc.com",
                        "machineId": "60bd5d38-dd9f-468b-a0f5-f3b78776b079"
                    },
                    "lastUpdateMicros": 0
                },
                "stateConfig": "user-up",
                "nodeReference": {
                    "id": "614b44da-60b7-35f0-921f-249a140bfb3a",
                    "kind": "cm:adc-core:current-config:ltm:node:adcnodestate",
                    "link": "https://localhost/mgmt/cm/adc-core/current-config/ltm/node/614b44da-60b7-35f0-921f-249a140bfb3a",
                    "name": "10.1.20.117",
                    "address": "10.1.20.117",
                    "partition": "Common"
                },
                "priorityGroup": 0,
                "sessionConfig": "user-enabled",
                "connectionLimit": 0,
                "lastUpdateMicros": 1602023307787543,
                "minMonitorHealth": 1,
                "monitorHttpReferences": [
                    {
                        "id": "58594b56-5520-3686-b7ed-851aa19099bb",
                        "kind": "cm:adc-core:current-config:ltm:monitor:http:adcmonitorhttpstate",
                        "link": "https://localhost/mgmt/cm/adc-core/current-config/ltm/monitor/http/58594b56-5520-3686-b7ed-851aa19099bb",
                        "name": "http",
                        "partition": "Common"
                    }
                ]
            },
            {
                "id": "a4040191-a157-332a-a3d4-c3ca91ff8be2",
                "kind": "cm:adc-core:current-config:ltm:pool:members:adcpoolmemberstate",
                "name": "10.1.20.115:80",
                "port": 80,
                "ratio": 1,
                "selfLink": "https://localhost/mgmt/cm/adc-core/current-config/ltm/pool/ef21f8dd-c75d-328d-8f21-8816a76d8c1b/members/a4040191-a157-332a-a3d4-c3ca91ff8be2",
                "partition": "Common",
                "rateLimit": "disabled",
                "generation": 14,
                "parentInfo": {
                    "id": "ef21f8dd-c75d-328d-8f21-8816a76d8c1b",
                    "name": "Pool",
                    "subPath": "app2",
                    "selfLink": "https://localhost/mgmt/cm/adc-core/current-config/ltm/pool/ef21f8dd-c75d-328d-8f21-8816a76d8c1b",
                    "partition": "legacy",
                    "generation": 0,
                    "deviceReference": {
                        "id": "60bd5d38-dd9f-468b-a0f5-f3b78776b079",
                        "kind": "shared:resolver:device-groups:restdeviceresolverdevicestate",
                        "link": "https://localhost/mgmt/shared/resolver/device-groups/cm-adccore-allbigipDevices/devices/60bd5d38-dd9f-468b-a0f5-f3b78776b079",
                        "name": "SEA-vBIGIP01.termmarc.com",
                        "machineId": "60bd5d38-dd9f-468b-a0f5-f3b78776b079"
                    },
                    "lastUpdateMicros": 0
                },
                "stateConfig": "user-up",
                "nodeReference": {
                    "id": "26baebd5-8ca5-3976-9949-70036f65349e",
                    "kind": "cm:adc-core:current-config:ltm:node:adcnodestate",
                    "link": "https://localhost/mgmt/cm/adc-core/current-config/ltm/node/26baebd5-8ca5-3976-9949-70036f65349e",
                    "name": "10.1.20.115",
                    "address": "10.1.20.115",
                    "partition": "Common"
                },
                "priorityGroup": 0,
                "sessionConfig": "user-enabled",
                "connectionLimit": 0,
                "lastUpdateMicros": 1602023307787290,
                "minMonitorHealth": 1,
                "monitorHttpReferences": [
                    {
                        "id": "58594b56-5520-3686-b7ed-851aa19099bb",
                        "kind": "cm:adc-core:current-config:ltm:monitor:http:adcmonitorhttpstate",
                        "link": "https://localhost/mgmt/cm/adc-core/current-config/ltm/monitor/http/58594b56-5520-3686-b7ed-851aa19099bb",
                        "name": "http",
                        "partition": "Common"
                    }
                ]
            },
            {
                "id": "63c034a9-9369-3316-93d3-daa0e3a5d62d",
                "kind": "cm:adc-core:current-config:ltm:pool:members:adcpoolmemberstate",
                "name": "10.1.20.116:80",
                "port": 80,
                "ratio": 1,
                "selfLink": "https://localhost/mgmt/cm/adc-core/current-config/ltm/pool/ef21f8dd-c75d-328d-8f21-8816a76d8c1b/members/63c034a9-9369-3316-93d3-daa0e3a5d62d",
                "partition": "Common",
                "rateLimit": "disabled",
                "generation": 14,
                "parentInfo": {
                    "id": "ef21f8dd-c75d-328d-8f21-8816a76d8c1b",
                    "name": "Pool",
                    "subPath": "app2",
                    "selfLink": "https://localhost/mgmt/cm/adc-core/current-config/ltm/pool/ef21f8dd-c75d-328d-8f21-8816a76d8c1b",
                    "partition": "legacy",
                    "generation": 0,
                    "deviceReference": {
                        "id": "60bd5d38-dd9f-468b-a0f5-f3b78776b079",
                        "kind": "shared:resolver:device-groups:restdeviceresolverdevicestate",
                        "link": "https://localhost/mgmt/shared/resolver/device-groups/cm-adccore-allbigipDevices/devices/60bd5d38-dd9f-468b-a0f5-f3b78776b079",
                        "name": "SEA-vBIGIP01.termmarc.com",
                        "machineId": "60bd5d38-dd9f-468b-a0f5-f3b78776b079"
                    },
                    "lastUpdateMicros": 0
                },
                "stateConfig": "user-up",
                "nodeReference": {
                    "id": "c8ad57df-a7f1-3028-a4cd-074ff0082ce6",
                    "kind": "cm:adc-core:current-config:ltm:node:adcnodestate",
                    "link": "https://localhost/mgmt/cm/adc-core/current-config/ltm/node/c8ad57df-a7f1-3028-a4cd-074ff0082ce6",
                    "name": "10.1.20.116",
                    "address": "10.1.20.116",
                    "partition": "Common"
                },
                "priorityGroup": 0,
                "sessionConfig": "user-enabled",
                "connectionLimit": 0,
                "lastUpdateMicros": 1602023307787432,
                "minMonitorHealth": 1,
                "monitorHttpReferences": [
                    {
                        "id": "58594b56-5520-3686-b7ed-851aa19099bb",
                        "kind": "cm:adc-core:current-config:ltm:monitor:http:adcmonitorhttpstate",
                        "link": "https://localhost/mgmt/cm/adc-core/current-config/ltm/monitor/http/58594b56-5520-3686-b7ed-851aa19099bb",
                        "name": "http",
                        "partition": "Common"
                    }
                ]
            }
        ],
        "generation": 1,
        "kind": "cm:adc-core:current-config:ltm:pool:members:adcpoolmembercollectionstate",
        "lastUpdateMicros": 1602785635862603,
        "selfLink": "https://localhost/mgmt/cm/adc-core/current-config/ltm/pool/ef21f8dd-c75d-328d-8f21-8816a76d8c1b/members"
    }


Force-offline a Pool Member
^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. ``POST /mgmt/cm/adc-core/tasks/self-service``

Replace ``current-config`` with ``working-config``

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 3, 5

    {  
        "resourceReference":{
            "link":"https://localhost/mgmt/cm/adc-core/working-config/ltm/pool/ef21f8dd-c75d-328d-8f21-8816a76d8c1b/members/6bd14736-285f-3338-850d-ff2378817fc6"
        },
        "operation":"force-offline"
    }


Result:

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 6, 8

    {
        "resourceReference": {
            "link": "https://localhost/mgmt/cm/adc-core/working-config/ltm/pool/ef21f8dd-c75d-328d-8f21-8816a76d8c1b/members/6bd14736-285f-3338-850d-ff2378817fc6"
        },
        "operation": "force-offline",
        "id": "9bc4e08b-d7df-4051-9390-01d0be11bf0a",
        "status": "STARTED",
        "userReference": {
            "link": "https://localhost/mgmt/shared/authz/users/admin"
        },
        "identityReferences": [
            {
                "link": "https://localhost/mgmt/shared/authz/users/admin"
            }
        ],
        "ownerMachineId": "e8b6a888-24e4-426c-8088-542f69f6f78d",
        "taskWorkerGeneration": 1,
        "generation": 1,
        "lastUpdateMicros": 1602791454015097,
        "kind": "cm:adc-core:tasks:self-service:selfservicetaskitemstate",
        "selfLink": "https://localhost/mgmt/cm/adc-core/tasks/self-service/9bc4e08b-d7df-4051-9390-01d0be11bf0a"
    }


2. ``GET /mgmt/cm/adc-core/tasks/self-service/c7d49112-5927-4c3f-b4d0-fff253494cf9``

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 3

    {
        "id": "9bc4e08b-d7df-4051-9390-01d0be11bf0a",
        "kind": "cm:adc-core:tasks:self-service:selfservicetaskitemstate",
        "status": "FINISHED",
        "selfLink": "https://localhost/mgmt/cm/adc-core/tasks/self-service/9bc4e08b-d7df-4051-9390-01d0be11bf0a",
        "username": "admin",
        "operation": "force-offline",
        "generation": 2,
        "endDateTime": "2020-10-15T12:50:56.876-0700",
        "startDateTime": "2020-10-15T12:50:54.032-0700",
        "userReference": {
            "link": "https://localhost/mgmt/shared/authz/users/admin"
        },
        "ownerMachineId": "e8b6a888-24e4-426c-8088-542f69f6f78d",
        "deviceReference": {
            "link": "https://localhost/mgmt/shared/resolver/device-groups/cm-adccore-allbigipDevices/devices/60bd5d38-dd9f-468b-a0f5-f3b78776b079"
        },
        "lastUpdateMicros": 1602791456926657,
        "resourceReference": {
            "link": "https://localhost/mgmt/cm/adc-core/working-config/ltm/pool/ef21f8dd-c75d-328d-8f21-8816a76d8c1b/members/6bd14736-285f-3338-850d-ff2378817fc6"
        },
        "identityReferences": [
            {
                "link": "https://localhost/mgmt/shared/authz/users/admin"
            }
        ]
    }

3. Login to BIG-IQ as **david** and navigate to **Deployment > Quick Updates > Local Traffic & Network**.

.. image:: ../pictures/module6/lab-5-2.png
  :scale: 40%
  :align: center

4. Now logout from the **david** session and login to BIG-IQ as **paula**.

.. image:: ../pictures/module6/lab-5-3.png
  :scale: 40%
  :align: center
