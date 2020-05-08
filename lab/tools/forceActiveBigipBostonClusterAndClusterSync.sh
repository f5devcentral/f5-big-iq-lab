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
    ssh -o StrictHostKeyChecking=no admin@$ip tmsh show /cm failover-status
else
    echo -e "BOS-vBIGIP01.termmarc.com is ACTIVE, nothing to do."
fi

## WA UDF RE-SYNC CLUSTER AFTER RE-LICENCED => Run below checks only first within the fist 30min the lab started
minutes=`awk '{print $0/60;}' /proc/uptime`;
if [ $(echo "$minutes > 30" | bc) -eq 0  ]
then
    ssh -o StrictHostKeyChecking=no admin@$ip tmsh show /cm sync-status | grep Status | grep "In Sync"
    # if 0 = Not In Sync
    if [  $? == 1 ]; then
        echo -e "BOS cluster is not in Sync: trigger sync ($minutes)."
        ssh -o StrictHostKeyChecking=no admin@$ip tmsh run cm config-sync force-full-load-push to-group datasync-global-dg
        ssh -o StrictHostKeyChecking=no admin@$ip tmsh show /cm sync-status
    else
        echo -e "BOS cluster in sync, nothing to do ($minutes)."
    fi
else
    echo -e "It's been more than 30min ($minutes). Manually re-sync the BOS cluster if needed."
fi