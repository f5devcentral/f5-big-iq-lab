#!/bin/bash
# Uncomment set command below for code debuging bash
set -x

STATUS=$(/etc/init.d/xrdp status | grep -i active | awk '{print $2}')
# Most services will return something like "OK" if they are in fact "OK"
test "$STATUS" = "active" || sudo /etc/init.d/xrdp restart

STATUS=$(/etc/init.d/freeradius status | grep -e active | awk '{print $2}') # to remove once radius docker is used
# Most services will return something like "OK" if they are in fact "OK"
test "$STATUS" = "active" || sudo /etc/init.d/freeradius restart # to remove once radius docker is used

STATUS=$(/etc/init.d/isc-dhcp-server status | grep -e active | awk '{print $2}')
# Most services will return something like "OK" if they are in fact "OK"
test "$STATUS" = "active" || sudo /etc/init.d/isc-dhcp-server restart

STATUS=$(ps -ef | grep Xtigervnc | grep -v grep | awk '{print $8}' | awk -F '/' '{print $4}')
# Most services will return something like "OK" if they are in fact "OK"
test "$STATUS" = "Xtigervnc" || /usr/bin/vncserver :1 -geometry 1280x800 -depth 24

STATUS=$(ps -ef | grep websockify | grep -v grep | awk '{print $9}' | awk -F '/' '{print $4}' | uniq)
# Most services will return something like "OK" if they are in fact "OK"
test "$STATUS" = "websockify" || /usr/bin/websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 6080 localhost:5901
