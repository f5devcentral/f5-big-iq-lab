#!/bin/bash

function pause(){
   read -p "$*"
}

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
    [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
    
    ready=$(grep COMPLETED ../update_git.log | wc -l)
    if [[  $ready == 1 ]]; then

        echo -e "\n* Cleanup logs on the Lamp server...\n"
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

        echo -e "\n* Shutdown BIG-IP and BIG-IQ gracefully...\n"
        ssh -o StrictHostKeyChecking=no admin@10.1.1.4 shutdown -H now &
        sleep 1
        ssh -o StrictHostKeyChecking=no admin@10.1.1.6 shutdown -H now &
        sleep 1
        ssh -o StrictHostKeyChecking=no admin@10.1.1.8 shutdown -H now &
        sleep 1
        ssh -o StrictHostKeyChecking=no admin@10.1.1.10 shutdown -H now &
        sleep 1
        ssh -o StrictHostKeyChecking=no admin@10.1.1.7 shutdown -H now &
        sleep 1
        ssh -o StrictHostKeyChecking=no admin@10.1.1.11 shutdown -H now &
    
        echo -e "Wait at least 15min before saving the BP."
        secs=$((15 * 60))
        while [ $secs -gt 0 ]; do
            echo -ne "$secs\033[0K\r"
            sleep 1
            : $((secs--))
        done
        echo -e "\n\nDouble check the BIG-IPs and BIG-IQ are shutdown.\n"
    else
        echo -e "The Lamp server initialisation did not complete, please check ~/upgrade_git.log and wait for it to be COMPLETED."
    fi
fi