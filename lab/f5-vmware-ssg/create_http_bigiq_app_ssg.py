#! /usr/bin/env python
import time
import requests
import pprint

TEMPLATES_URL = '/mgmt/cm/global/templates' # list of templates
APPLY_TEMPLATE_URL = '/mgmt/cm/global/tasks/apply-template' # creates applications
SSG_URL = '/mgmt/cm/cloud/service-scaling-groups' # lists BIG-IP devices

# Change as needed
HOST = 'https://10.1.1.4'
APP_NAME = "game.site24ssg.example.com"

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

# Get the target ssg
the_url = HOST + SSG_URL  + "?$filter=name eq 'vmware-ssg'"
ssg = session.get(HOST + SSG_URL  + "?$filter=name eq 'vmware-ssg'").json()['items'][0] # Just pick the first one
ssg_link = ssg["selfLink"]

post_body = """
{
    "resources": {
        "ltm:virtual::b487671f29ba": [
            {
                "parameters": {
                    "name": "virtual",
                    "destinationAddress": "10.1.10.124",
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
                                    "link": "#/resources/ltm:node:9e76a6323321/10.1.20.124",
                                    "fullPath": "# 10.1.20.124"
                                }
                            },
                            "parametersToRemove": []
                        },
                        {
                            "parameters": {
                                "port": "80",
                                "nodeReference": {
                                    "link": "#/resources/ltm:node:9e76a6323321/10.1.20.125",
                                    "fullPath": "# 10.1.20.125"
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
                    "name": "10.1.20.124",
                    "address": "10.1.20.124"
                },
                "parametersToRemove": []
            },
            {
                "parameters": {
                    "name": "10.1.20.125",
                    "address": "10.1.20.125"
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
    "ssgReference": {
        "link": "%s"
    },
    "subPath": "%s",
    "templateReference": {
        "link": "%s"
    },
    "mode": "CREATE"
}
""" % (APP_NAME, ssg_link, APP_NAME, template_link)

# start the task
apply_template_task = session.post(HOST + APPLY_TEMPLATE_URL, data=post_body).json()
link = apply_template_task['selfLink']

while apply_template_task['status'] not in ['FINISHED', 'FAILED', 'CANCELED']:
    apply_template_task = session.get(link.replace('https://localhost', HOST)).json()
    pretty_print('Polling task, Status: %s' % apply_template_task['status'])
    time.sleep(10)

if apply_template_task['status'] == 'FAILED':
    pretty_print('Task Failed: %s' % apply_template_task['errorMessage'])
