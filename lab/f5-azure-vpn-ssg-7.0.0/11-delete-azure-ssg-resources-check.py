#! /usr/bin/env python
import time
import requests
import pprint
import yaml
with open('config.yml', 'r') as f:
    doc = yaml.load(f)
PREFIX = doc["PREFIX"]
SSG_NAME = PREFIX + '-azure-ssg'

SSG_URL = '/mgmt/cm/cloud/service-scaling-groups' # lists SSG

# Change as needed
HOST = 'https://10.1.1.4'

pretty_print = pprint.PrettyPrinter(indent=2, depth=4).pprint

session = requests.Session()
requests.packages.urllib3.disable_warnings()
session.verify = False # BIG-IQ uses self-signed cert. Note: you can also supply a CA signed cert instead

session.auth = ('admin', 'purple123') # BIG-IQ must be configured for basic auth, in the console run `set-basic-auth on`

# Get the target SSG
the_url = HOST + SSG_URL + "?$filter=name eq '" + SSG_NAME + "'"
print(the_url)
device = session.get(HOST + SSG_URL + "?$filter=name eq '" + SSG_NAME + "'").json()
#print(device)
device_link = device['items'][0]["selfLink"]

# check if SSG online
device_status = device['items'][0]["status"]
#print(device_status)

pretty_print('Loop to check SSG status (every min). Expected time: ~5 min')

while device_status:
    device = session.get(HOST + SSG_URL + "?$filter=name eq '" + SSG_NAME + "'").json()
    try:
        device_status = device['items'][0]["status"]
        pretty_print('SSG Status: %s' % device_status)
        time.sleep(60)
        if  device_status == 'FAILED':
            pretty_print('SSG status FAILED, SSG not deleted correctly.')
            exit()
    except IndexError:
        pretty_print('SSG deleted, moving on.')
        exit()
