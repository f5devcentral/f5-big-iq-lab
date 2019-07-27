#! /usr/bin/env python
import time
import requests
import pprint
import yaml
with open('config.yml', 'r') as f:
    doc = yaml.load(f)
PREFIX = doc["PREFIX"]
NODE_ADDRESS = doc["NODE_ADDRESS"]
APP_NAME = PREFIX + '-app-azure'
SSG_NAME = PREFIX + '-azure-ssg'
#print PREFIX
#print SSG_NAME
#print APP_NAME
#print NODE_ADDRESS


TEMPLATES_URL = '/mgmt/cm/global/templates' # list of templates
APPLY_TEMPLATE_URL = '/mgmt/cm/global/tasks/apply-template' # creates applications
SSG_URL = '/mgmt/cm/cloud/service-scaling-groups' # lists SSG

# Change as needed
HOST = 'https://10.1.1.4'

pretty_print = pprint.PrettyPrinter(indent=2, depth=4).pprint

session = requests.Session()
requests.packages.urllib3.disable_warnings()
session.verify = False # BIG-IQ uses self-signed cert. Note: you can also supply a CA signed cert instead

session.auth = ('admin', 'purple123') # BIG-IQ must be configured for basic auth, in the console run `set-basic-auth on`

# Get the template
the_url = HOST + TEMPLATES_URL + "?$filter=name eq 'Default-AWS-f5-HTTPS-offload-lb-template'"
print(the_url)
templates = session.get(HOST + TEMPLATES_URL + "?$filter=name eq 'Default-AWS-f5-HTTPS-offload-lb-template'").json()
#print(templates)
template_link = templates['items'][0]["selfLink"]

# Get the target SSG
the_url = HOST + SSG_URL + "?$filter=name eq '" + SSG_NAME + "'"
print(the_url)
device = session.get(HOST + SSG_URL + "?$filter=name eq '" + SSG_NAME + "'").json()
#print(device)
device_link = device['items'][0]["selfLink"]

# check if SSG online
device_status = device['items'][0]["status"]
#print(device_status)

pretty_print('Loop to check SSG status (every min). Expected time: ~15 min')

while device_status not in ['READY']:
    device = session.get(HOST + SSG_URL + "?$filter=name eq '" + SSG_NAME + "'").json()
    device_status = device['items'][0]["status"]
    pretty_print('SSG Status: %s' % device_status)
    time.sleep(60)
    if  device_status == 'FAILED':
        pretty_print('SSG status FAILED, Application not created. Please check your SSG configuration.')
        exit()

    if  device_status == 'PAUSED':
        pretty_print('SSG status PAUSED, Application not created. Check your VPN is UP. You may retry app creation afterward: # python 09-create-azure-waf-app.py')
        exit()

pretty_print('Wait for an additonal 2 min to stabilize the SSG.')
time.sleep(120)

post_body = """
{
    "resources": {
        "ltm:virtual:7a5f7da91996": [
            {
                "parameters": {
                    "name": "default_vs"
                },
                "parametersToRemove": [],
                "subcollectionResources": {
                    "profiles:14c995c33411": [
                        {
                            "parameters": {},
                            "parametersToRemove": []
                        }
                    ],
                    "profiles:8ba4bb101701": [
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
                    ]
                }
            }
        ],
        "ltm:pool:be70d46c6d73": [
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
                                    "link": "#/resources/ltm:node:45391b57b104/%s",
                                    "fullPath": "# %s"
                                }
                            },
                            "parametersToRemove": []
                        }
                    ]
                }
            }
        ],
		"ltm:node:45391b57b104": [
            {
                "parameters": {
                    "name": "%s",
                    "address": "%s"
                },
                "parametersToRemove": []
            }
        ],
        "ltm:monitor:http:fd07629373b0": [
            {
                "parameters": {
                    "name": "monitor-http"
                },
                "parametersToRemove": []
            }
        ],
        "ltm:profile:client-ssl:14c995c33411": [
            {
                "parameters": {
                    "name": "clientssl"
                },
                "parametersToRemove": []
            }
        ],
        "ltm:profile:http:8ba4bb101701": [
            {
                "parameters": {
                    "name": "profile_http"
                },
                "parametersToRemove": []
            }
        ]
    },
    "addAnalytics": true,
    "configSetName": "%s",
    "ssgReference": {
        "link": "%s"
    },
    "azureLoadBalancer": {
        "listeners": [
            {
                "loadBalancerPort": 443,
                "instancePort": 443
            },
            {
                "loadBalancerPort": 80,
                "instancePort": 80
            }
        ]
    },
    "subPath": "%s",
    "templateReference": {
        "link": "%s"
    },
    "mode": "CREATE"
}
""" % (NODE_ADDRESS, NODE_ADDRESS, NODE_ADDRESS, NODE_ADDRESS, APP_NAME, device_link, APP_NAME, template_link)

# start the task
apply_template_task = session.post(HOST + APPLY_TEMPLATE_URL, data=post_body).json()
link = apply_template_task['selfLink']
#print(post_body)

pretty_print('Loop to check App creation status (every 30 sec). Expected time: ~4 min')

while apply_template_task['status'] not in ['FINISHED', 'FAILED', 'CANCELED']:
    apply_template_task = session.get(link.replace('https://localhost', HOST)).json()
    pretty_print('Polling task, Status: %s' % apply_template_task['status'])
    time.sleep(30)

if apply_template_task['status'] == 'FAILED':
    pretty_print('Task Failed: %s' % apply_template_task['errorMessage'])
