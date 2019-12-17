#! /usr/bin/env python
import time
import requests
import pprint

TEMPLATES_URL = '/mgmt/cm/global/templates' # list of templates
APPLY_TEMPLATE_URL = '/mgmt/cm/global/tasks/apply-template' # creates applications
DEVICES_URL = '/mgmt/shared/resolver/device-groups/cm-adccore-allbigipDevices/devices' # lists BIG-IP devices

# Change as needed
HOST = 'https://10.1.1.4'
APP_NAME = "site36.example.com"

pretty_print = pprint.PrettyPrinter(indent=2, depth=4).pprint

session = requests.Session()
requests.packages.urllib3.disable_warnings()
session.verify = False # BIG-IQ uses self-signed cert. Note: you can also supply a CA signed cert instead

session.auth = ('admin', 'purple123') # BIG-IQ must be configured for basic auth, in the console run `set-basic-auth on`

# Get the template
the_url = HOST + TEMPLATES_URL + "?$filter=name eq 'Default-f5-HTTPS-WAF-lb-template'"
print(the_url)
templates = session.get(HOST + TEMPLATES_URL + "?$filter=name eq 'Default-f5-HTTPS-WAF-lb-template'").json()
template_link = templates['items'][0]["selfLink"]

# Get the target device
the_url = HOST + DEVICES_URL  + "?$filter=managementAddress eq '10.1.1.8'"
device = session.get(HOST + DEVICES_URL  + "?$filter=managementAddress eq '10.1.1.8'").json()['items'][0] # Just pick the first one
device_link = device["selfLink"]

post_body = """
{
    "resources": {
        "ltm:virtual:90735960bf4b": [
            {
                "parameters": {
                    "name": "default_vs_443",
                    "destinationAddress": "10.1.10.136",
                    "mask": "255.255.255.255",
                    "destinationPort": "443"
                },
                "parametersToRemove": [],
                "subcollectionResources": {
                    "profiles:78b1bcfdafad": [
                        {
                            "parameters": {},
                            "parametersToRemove": []
                        }
                    ],
                    "profiles:2f52acac9fde": [
                        {
                            "parameters": {},
                            "parametersToRemove": []
                        }
                    ],
                    "profiles:9448fe71611e": [
                        {
                            "parameters": {},
                            "parametersToRemove": []
                        }
                    ],
                    "profiles:b0f36f336181": [
                        {
                            "parameters": {},
                            "parametersToRemove": []
                        }
                    ],
                    "security-shared:virtuals:3fdc5b0539bb": [
                        {
                            "parameters": {},
                            "parametersToRemove": []
                        }
                    ]
                }
            }
        ],
        "ltm:virtual:3341f412b980": [
            {
                "parameters": {
                    "name": "default_redirect_vs_80",
                    "destinationAddress": "10.1.10.136",
                    "mask": "255.255.255.255",
                    "destinationPort": "80"
                },
                "parametersToRemove": [],
                "subcollectionResources": {
                    "profiles:2f52acac9fde": [
                        {
                            "parameters": {},
                            "parametersToRemove": []
                        }
                    ],
                    "profiles:9448fe71611e": [
                        {
                            "parameters": {},
                            "parametersToRemove": []
                        }
                    ],
                    "security-shared:virtuals:3fdc5b0539bb": [
                        {
                            "parameters": {},
                            "parametersToRemove": []
                        }
                    ]
                }
            }
        ],
        "ltm:node:c072248f8e6a": [
            {
                "parameters": {
                    "name": "10.1.20.110",
                    "address": "10.1.20.110"
                },
                "parametersToRemove": []
            },
            {
                "parameters": {
                    "name": "10.1.20.111",
                    "address": "10.1.20.111"
                },
                "parametersToRemove": []
            }
        ],
        "ltm:pool:8bc5b256f9d1": [
            {
                "parameters": {
                    "name": "pool_0"
                },
                "parametersToRemove": [],
                "subcollectionResources": {
                    "members:dec6d24dc625": [
                        {
                            "parameters": {
                                "port": 80,
                                "nodeReference": {
                                    "link": "#/resources/ltm:node:c072248f8e6a/10.1.20.110",
                                    "fullPath": "# 10.1.20.110"
                                }
                            },
                            "parametersToRemove": []
                        },
                        {
                            "parameters": {
                                "port": "80",
                                "nodeReference": {
                                    "link": "#/resources/ltm:node:c072248f8e6a/10.1.20.111",
                                    "fullPath": "# 10.1.20.111"
                                }
                            },
                            "parametersToRemove": []
                        }
                    ]
                }
            }
        ],
        "ltm:monitor:http:18765a198150": [
            {
                "parameters": {
                    "name": "monitor-http"
                },
                "parametersToRemove": []
            }
        ],
        "ltm:profile:client-ssl:78b1bcfdafad": [
            {
                "parameters": {
                    "name": "clientssl"
                },
                "parametersToRemove": []
            }
        ],
        "ltm:profile:http:2f52acac9fde": [
            {
                "parameters": {
                    "name": "profile_http"
                },
                "parametersToRemove": []
            }
        ]
    },
    "domains": [
        {
            "domainName": "%s"
        }
    ],
    "configSetName": "%s",
    "defaultDeviceReference": {
        "link": "%s"
    },
    "subPath": "%s",
    "templateReference": {
        "link": "%s"
    },
    "mode": "CREATE"
}
""" % (APP_NAME, APP_NAME, device_link, APP_NAME, template_link)

# start the task
apply_template_task = session.post(HOST + APPLY_TEMPLATE_URL, data=post_body).json()
link = apply_template_task['selfLink']

while apply_template_task['status'] not in ['FINISHED', 'FAILED', 'CANCELED']:
    apply_template_task = session.get(link.replace('https://localhost', HOST)).json()
    pretty_print('Polling task, Status: %s' % apply_template_task['status'])
    time.sleep(10)

if apply_template_task['status'] == 'FAILED':
    pretty_print('Task Failed: %s' % apply_template_task['errorMessage'])
