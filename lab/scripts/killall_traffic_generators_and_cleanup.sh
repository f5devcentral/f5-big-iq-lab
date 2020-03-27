#!/bin/bash

type=$(cat /sys/hypervisor/uuid | grep ec2 | wc -l)
if [[  $type == 1 ]]; then
    echo "AWS"
else
    echo "Ravello"
fi

echo -e "* kill all jobs in sleep"
sudo killall sleep > /dev/null 2>&1
sudo killall perl > /dev/null 2>&1

for filename in ./*sh; do
    filename=${filename:2:${#filename}}
    echo -e "* $filename"
    for process in $(ps -ef | grep $filename | grep -v grep | grep -v $0 | grep -v reactivate_licenses.sh | awk '{print $2}'); do
      echo -e "\tkill -9 $process"
      sudo kill -9 $process
    done
done

# Kill some extra stuff (launched by generate_dns_ddos_traffic_real.sh)
sudo killall nping hping3

# Cleanup Logs:
rm -f ~/f5-demo-bigiq-analytics-export-restapi/input.json*
rm -f ~/scripts/dnstargets.txt
rm -f ~/splunk-token

rm -f ~/update_git.log
rm -f ~/.bash_history
rm -f ~/.aws
rm -rf ~/scripts/logs
rm -f ~/f5-vmware-ssg/*.log
## Below shouldn't be needed anymore after moving all logs under ~/scripts/logs
rm -f ~/f5-demo-bigiq-analytics-export-restapi/*log
rm -f ~/f5-demo-app-troubleshooting/*log
rm -f ~/ldap/f5-ldap.log
rm -f ~/asm-brute-force/*.log
rm -f ~/scripts/*.log
rm -f ~/ldap/f5-ldap.log