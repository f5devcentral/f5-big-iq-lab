#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

# BIG-IQ must be configured for basic auth, in the console run `set-basic-auth on`
bigiq="10.1.1.4"
bigiq_user="root"
bigiq_password="purple123" 

script="$0"
basename="$(dirname $script)"
echo $basename
cd $basename

# wait system is up
sleep 60

while [[ $state != "Active" ]] && [[ $state != "NO LICENSE" ]] && [[ $state != "LICENSE EXPIRED" ]]
do
    echo -e "\nTIME:: $(date +"%H:%M")"
    sshpass -p $bigiq_password ssh-copy-id -o StrictHostKeyChecking=no $bigiq_user@$bigiq
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 $bigiq_user@$bigiq cat /var/prompt/ps1 > state 2>/dev/null
    state=$(cat state)
    if [[ -z $state ]]; then
        state="n/a"
    fi
    if [[ $state == "Active" ]]; then
        echo -e "\n\nBIG-IQ Application is $state on $bigiq ... sleep for 1 min ..."
        sleep 60
        ssh $bigiq_user@$bigiq bigstart restart restjavad
        echo -e "\nbigstart restart restjavad completed."
        exit 0;
    else
        echo -e "\n\nBIG-IQ Application is $state on $bigiq"
    fi
    sleep 15
done

echo -e "\nTIME:: $(date +"%H:%M")"