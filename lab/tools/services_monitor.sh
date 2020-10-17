#!/bin/bash
# Uncomment set command below for code debuging bash
set -x

STATUS=$(/etc/init.d/xrdp status | grep -i active | awk '{print $2}')
# Most services will return something like "OK" if they are in fact "OK"
test "$STATUS" = "active" || sudo /etc/init.d/xrdp restart
