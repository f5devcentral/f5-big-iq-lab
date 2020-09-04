#!/bin/bash

function pause(){
   read -p "$*"
}

# Usage
if [[ "$1" != "save" ]]; then
    echo -e "\nUsage: ${RED} $0 <save>${NC}\n"
fi

type=$(cat /sys/hypervisor/uuid 2>/dev/null | grep ec2 | wc -l)
if [[  $type == 1 ]]; then
    echo "Hypervisor: AWS"
else
    echo "Hypervisor: Unknown"
fi

echo -e "\n* Kill all jobs in sleep..."
ps -ef | grep sleep | grep -v grep
sudo killall sleep
ps -ef | grep perl | grep -v grep
sudo killall sh
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

if [[ "$1" = "save" ]]; then

    echo -e "First step clean the logs on the Lamp server, then shut down BIG-IP/IQ gracefully."
    
    ready=$(grep COMPLETED ../update_git.log | wc -l)
    if [[  $ready == 1 ]]; then

        echo -e "\n* Cleanup logs on the Lamp server...\n"
        [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
        rm -f ~/f5-demo-bigiq-analytics-export-restapi/input.json*
        rm -f ~/splunk-token
        rm -fr ~/gitlab/gitlab ~/gitlab/gitlab-runner1-config

        rm -f ~/update_git.log
        rm -f ~/.bash_history
        rm -rf ~/.aws

        rm -f ~/traffic-scripts/logs/*.log
        rm -f ~/traffic-scripts/dnstargets.txt
        rm -f ~/tools/logs/*.log
        rm -f ~/ldap/f5-ldap.log

        rm -f ~/f5-vmware/*.log

        echo -e "\n\nYou can nominate the blueprint now.\n"
    else
        echo -e "The Lamp server initialisation did not complete, please check ~/upgrade_git.log and wait for it to be COMPLETED."
    fi
fi