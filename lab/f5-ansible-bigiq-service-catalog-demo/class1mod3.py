#! /usr/bin/env python
import time
import requests
import pprint

TEMPLATES_URL = '/mgmt/cm/global/templates' # list of templates
APPLY_TEMPLATE_URL = '/mgmt/cm/global/tasks/apply-template' # creates applications
DEVICES_URL = '/mgmt/shared/resolver/device-groups/cm-adccore-allbigipDevices/devices' # lists BIG-IP devices

# Change as needed
HOST = 'https://10.1.1.4'
APP_NAME = "site20.example.com"

pretty_print = pprint.PrettyPrinter(indent=2, depth=4).pprint

session = requests.Session()
requests.packages.urllib3.disable_warnings()
session.verify = False # BIG-IQ uses self-signed cert. Note: you can also supply a CA signed cert instead

session.auth = ('admin', 'purple123') # BIG-IQ must be configured for basic auth, in the console run `set-basic-auth on`

# Get the template
the_url = HOST + TEMPLATES_URL + "?$filter=name eq 'Default-f5-HTTP-lb-template'"
print(the_url)
templates = session.get(HOST + TEMPLATES_URL + "?$filter=name eq 'Default-f5-HTTP-lb-template'").json()
template_link = templates['items'][0]["selfLink"]

# Get the target device
the_url = HOST + DEVICES_URL  + "?$filter=managementAddress eq '10.1.1.7'"
device = session.get(HOST + DEVICES_URL  + "?$filter=managementAddress eq '10.1.1.7'").json()['items'][0] # Just pick the first one
device_link = device["selfLink"]

post_body = """
{
    "resources": {
        "ltm:virtual::b487671f29ba": [
            {
                "parameters": {
                    "name": "virtual",
                    "destinationAddress": "10.1.10.120",
                    "mask": "255.255.255.255",
                    "destinationPort": "80"
                },
                "parametersToRemove": [],
                "subcollectionResources": {
                    "profiles:9448fe71611e": [
                        {
                            "parameters": {},
                            "parametersToRemove": []
                        }
                    ],
                    "profiles:03a4950ab656": [
                        {
                            "parameters": {},
                            "parametersToRemove": []
                        }
                    ]
                }
            }
        ],
        "ltm:pool:9a593d17495b": [
            {
                "parameters": {
                    "name": "pool_0"
                },
                "parametersToRemove": [],
                "subcollectionResources": {
                    "members:5109c66dfbac": [
                        {
                            "parameters": {
                                "port": 80,
                                "nodeReference": {
                                    "link": "#/resources/ltm:node:9e76a6323321/10.1.20.120",
                                    "fullPath": "# 10.1.20.120"
                                }
                            },
                            "parametersToRemove": []
                        },
                        {
                            "parameters": {
                                "port": "80",
                                "nodeReference": {
                                    "link": "#/resources/ltm:node:9e76a6323321/10.1.20.121",
                                    "fullPath": "# 10.1.20.121"
                                }
                            },
                            "parametersToRemove": []
                        }
                    ]
                }
            }
        ],
        "ltm:node:9e76a6323321": [
            {
                "parameters": {
                    "name": "10.1.20.120",
                    "address": "10.1.20.120"
                },
                "parametersToRemove": []
            },
            {
                "parameters": {
                    "name": "10.1.20.121",
                    "address": "10.1.20.121"
                },
                "parametersToRemove": []
            }
        ],
        "ltm:monitor:http:ea4346e49cdf": [
            {
                "parameters": {
                    "name": "monitor-http"
                },
                "parametersToRemove": []
            }
        ],
        "ltm:profile:http:03a4950ab656": [
            {
                "parameters": {
                    "name": "profile_http"
                },
                "parametersToRemove": []
            }
        ]
    },
    "addAnalytics": true,
    "domains": [],
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
""" % (APP_NAME, device_link, APP_NAME, template_link)

# start the task
apply_template_task = session.post(HOST + APPLY_TEMPLATE_URL, data=post_body).json()
link = apply_template_task['selfLink']

while apply_template_task['status'] not in ['FINISHED', 'FAILED', 'CANCELED']:
    apply_template_task = session.get(link.replace('https://localhost', HOST)).json()
    pretty_print('Polling task, Status: %s' % apply_template_task['status'])
    time.sleep(10)

if apply_template_task['status'] == 'FAILED':
    pretty_print('Task Failed: %s' % apply_template_task['errorMessage'])
