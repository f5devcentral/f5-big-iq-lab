#!/bin/bash
# Uncomment set command below for code debuging bash
set -x

STATUS=$(/etc/init.d/xrdp status | grep -i active | awk '{print $2}')
# Most services will return something like "OK" if they are in fact "OK"
test "$STATUS" = "active" || sudo /etc/init.d/xrdp restart


type=$(cat /sys/hypervisor/uuid 2>/dev/null | grep ec2 | wc -l)
if [[  $type == 1 ]]; then
    echo "Hypervisor: AWS"
    STATUS=$(ps -ef | grep Xtigervnc | grep -v grep | awk '{print $8}' | sed 's#/usr/bin/##g')
    # Most services will return something like "OK" if they are in fact "OK"
    test "$STATUS" = "Xtigervnc" || /usr/bin/vncserver :1 -geometry 1280x800 -depth 24

    STATUS=$(ps -ef | grep websockify | grep -v grep | awk '{print $9}' | awk -F '/' '{print $4}' | uniq)
    # Most services will return something like "OK" if they are in fact "OK"
    test "$STATUS" = "websockify" || /usr/bin/websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 6080 localhost:5901
else
    echo "Hypervisor: UDF Hypervisor or others"
    STATUS=$(ps -ef | grep websockify | grep -v grep | awk '{print $9}' | awk -F '/' '{print $4}' | uniq)
    # Most services will return something like "OK" if they are in fact "OK"
    test "$STATUS" = "websockify" || /usr/bin/websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 6080 localhost:5900
fi
