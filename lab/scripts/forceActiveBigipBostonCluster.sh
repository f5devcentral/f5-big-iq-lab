#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

#BOS-vBIGIP02.termmarc.com
ip="10.1.1.10"

ssh -o StrictHostKeyChecking=no admin@$ip tmsh show /cm failover-status | grep ACTIVE
# if 0 = STANDBY
if [  $? == 0 ]; then
    echo -e "BOS-vBIGIP02.termmarc.com is ACTIVE: trigger failover so BOS-vBIGIP01 is ACTIVE."
    ssh -o StrictHostKeyChecking=no admin@$ip tmsh run /sys failover standby
    ssh -o StrictHostKeyChecking=no admin@$ip tmsh run cm config-sync force-full-load-push to-group datasync-global-dg
else
    echo -e "BOS-vBIGIP01.termmarc.com is ACTIVE, nothing to do."
fi