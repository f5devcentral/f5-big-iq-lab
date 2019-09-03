#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

## THIS IS A WA ONLY FOR RAVELLO BLUEPRINT

IP=$(/sbin/ifconfig eth0 | grep inet | awk '{print $2}')
# Most services will return something like "OK" if they are in fact "OK"
test "$IP" = "10.1.1.5" || sudo netplan apply