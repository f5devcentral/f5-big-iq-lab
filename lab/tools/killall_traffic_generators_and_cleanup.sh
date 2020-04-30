#!/bin/bash

type=$(cat /sys/hypervisor/uuid 2>/dev/null | grep ec2 | wc -l)
if [[  $type == 1 ]]; then
    echo "Hypervisor: AWS"
else
    echo "Hypervisor: Ravello"
fi

echo -e "\n* Kill all jobs in sleep..."
ps -ef | grep sleep | grep -v grep
sudo killall sleep
ps -ef | grep perl | grep -v grep
sudo killall perl

echo -e "\n* Kill all traffic generators jobs running..."
cd ../traffic-scripts
for filename in ./*sh; do
    filename=${filename:2:${#filename}}
    echo -e "   * $filename"
    for process in $(ps -ef | grep $filename | grep -v grep | grep -v $0 | awk '{print $2}'); do
      echo -e "      kill -9 $process"
      sudo kill -9 $process
    done
done

echo 

# Kill some extra stuff (launched by generate_dns_ddos_traffic_real.sh)
ps -ef | grep ping | grep -v grep
sudo killall nping hping3

echo

if [[ "$1" = "cleanup" ]]; then
    echo -e "\n* Cleanup logs...\n"
    # Cleanup Logs:
    rm -f ~/f5-demo-bigiq-analytics-export-restapi/input.json*
    rm -f ~/splunk-token

    rm -f ~/update_git.log
    rm -f ~/.bash_history
    rm -rf ~/.aws

    rm -f ~/traffic-scripts/logs/*.log
    rm -f ~/traffic-scripts/dnstargets.txt
    rm -f ~/tools/logs/*.log
    rm -f ~/ldap/f5-ldap.log

    rm -f ~/f5-vmware/*.log
    echo -e "... done! \n"
fi