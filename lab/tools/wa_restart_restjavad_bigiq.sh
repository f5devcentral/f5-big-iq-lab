#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

# BIG-IQ must be configured for basic auth, in the console run `set-basic-auth on`
bigiq="10.1.1.4"
bigiq_user="root"
bigiq_password="purple123"

echo -e "\nTIME:: $(date +"%H:%M")"

echo -e "start"

sshpass -p $bigiq_password ssh-copy-id -i /home/f5/.ssh/id_rsa.pub -o StrictHostKeyChecking=no $bigiq_user@$bigiq
sudo rm -f /tmp/state
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 $bigiq_user@$bigiq cat /var/prompt/ps1 > /tmp/state
state=$(cat /tmp/state)

while [[ $state = "Active" ]]
do
    echo -e "\nTIME:: $(date +"%H:%M")"
    sshpass -p $bigiq_password ssh-copy-id -i /home/f5/.ssh/id_rsa.pub -o StrictHostKeyChecking=no $bigiq_user@$bigiq
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 $bigiq_user@$bigiq cat /var/prompt/ps1 > /tmp/state
    state=$(cat /tmp/state)
    if [[ -z $state ]]; then
        state="n/a"
    fi
    if [[ $state == "Active" ]]; then
        echo -e "\n\nBIG-IQ Application is $state on $bigiq ... sleep for 1 min 30 sec ..."
        secs=90
        while [ $secs -gt 0 ]; do
            echo -ne "$secs\033[0K\r"
            sleep 1
            : $((secs--))
        done
        ssh -o StrictHostKeyChecking=no $bigiq_user@$bigiq bigstart restart restjavad
        echo -e "\nbigstart restart restjavad completed."
        exit 0;
    else
        echo -e "\n\nBIG-IQ Application is $state on $bigiq"
    fi
    sleep 15
done

echo -e "end"

echo -e "\nTIME:: $(date +"%H:%M")"