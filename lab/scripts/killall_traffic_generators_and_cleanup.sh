#!/bin/bash

type=$(cat /sys/hypervisor/uuid 2>/dev/null | grep ec2 | wc -l)
if [[  $type == 1 ]]; then
    echo "Hypervisor: AWS"
else
    echo "Hypervisor: Ravello"
fi

echo -e "\n* Kill all jobs in sleep..."
sudo killall sleep
sudo killall perl

echo -e "\n* Kill all jobs running..."
for filename in ./*sh; do
    filename=${filename:2:${#filename}}
    echo -e "   * $filename"
    for process in $(ps -ef | grep $filename | grep -v grep | grep -v $0 | grep -v reactivate_licenses.sh | awk '{print $2}'); do
      echo -e "      kill -9 $process"
      sudo kill -9 $process
    done
done

echo 

# Kill some extra stuff (launched by generate_dns_ddos_traffic_real.sh)
sudo killall nping hping3

echo

if [[ "$1" = "cleanup" ]]; then
    echo -e "\n* Cleanup logs...\n"
    # Cleanup Logs:
    rm -f ~/f5-demo-bigiq-analytics-export-restapi/input.json*
    rm -f ~/scripts/dnstargets.txt
    rm -f ~/splunk-token

    rm -f ~/update_git.log
    rm -f ~/.bash_history
    rm -fr ~/.aws

    rm -rf ~/scripts/logs/*.log
    rm -f ~/f5-vmware-ssg/*.log
    ## Below shouldn't be needed anymore after moving all logs under ~/scripts/logs
    rm -f ~/f5-demo-bigiq-analytics-export-restapi/*log
    rm -f ~/f5-demo-app-troubleshooting/*log
    rm -f ~/ldap/f5-ldap.log
    rm -f ~/asm-brute-force/*.log
    rm -f ~/scripts/*.log
    rm -f ~/ldap/f5-ldap.log
    echo -e "... done! \n"
fi