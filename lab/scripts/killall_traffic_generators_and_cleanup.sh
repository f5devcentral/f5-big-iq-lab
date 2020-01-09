#!/bin/bash

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

# Reset default GW in case SSLO script gets kill in the middle of it
interface=$(ifconfig | grep -B 1 10.1.1.5 | grep -v 10.1.1.5 | awk -F':' '{ print $1 }')
type=$(cat /sys/hypervisor/uuid | grep ec2 | wc -l)
if [[  $type == 1 ]]; then
    echo "AWS"
    #sudo route del default gw 10.1.20.13
    #sudo route del default gw 10.1.20.7
    #sudo route add default gw 10.1.1.1
else
    echo "Ravello"
    sudo ip route change default via 10.1.1.2 dev $interface
fi

# Cleanup Logs:
rm -f ~/f5-demo-bigiq-analytics-export-restapi/input.json*
rm -f ~/f5-demo-bigiq-analytics-export-restapi/*log
rm -f ~/f5-demo-app-troubleshooting/*log
rm -f ~/asm-brute-force/*.log
rm -f ~/scripts/*.log
rm -f ~/splunk-token
rm -f ~/ldap/f5-ldap.log
rm -f ~/f5-vmware-ssg/*.log
rm -f ~/update_git.log
rm -f ~/.bash_history
rm -f ~/.aws