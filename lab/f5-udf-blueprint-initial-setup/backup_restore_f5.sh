#!/bin/bash

#set -x

function pause(){
   read -p "$*"
}


name[1]="SEA-vBIGIP01.termmarc.com"
ip[1]="10.1.1.7"
name[2]="BOS-vBIGIP01.termmarc.com"
ip[2]="10.1.1.8"
name[3]="BOS-vBIGIP02.termmarc.com"
ip[3]="10.1.1.10"
name[4]="PARIS-vBIGIP01.termmarc.com"
ip[4]="10.1.1.13"
name[5]="SJC-vBIGIP01.termmarc.com"
ip[5]="10.1.1.11"

d=$2

if [[ -z $1 ]]; then
    echo -e "\nOPTIONS: [backup, setup or restore] [date with 1st option restore only]\n"
    ls -lrth ./ucs | grep ucs

elif [[ "$1" = "backup" ]]; then
    echo -e "\n---------- BACKUP BIG-IPs -----------\n"
    for ((i=1; i <= ${#ip[@]}; i++)); do 
        echo -e "** ${ip[i]} - ${name[i]}\n"
        sshpass -p "purple123" ssh -o StrictHostKeyChecking=no root@${ip[i]} tmsh save sys ucs ${name[i]}-$(date +%m%d%y)
    done

    rm -rf ./ucs
    mkdir ucs

    for ((i=1; i <= ${#ip[@]}; i++)); do 
        echo -e "** $ip\n"
        sshpass -p "purple123" scp -o StrictHostKeyChecking=no root@${ip[i]}:/var/local/ucs/${name[i]}-$(date +%m%d%y).ucs ucs
    done

elif [[ "$1" = "setup" ]]; then

    echo -e "\n---------- INITIAL SETUP BIG-IPs -----------\n"

    echo -e "\nRun on all BIG-IPs:\n"
    echo -e 'echo "root:default" | chpasswd'
    echo -e 'echo "admin:admin" | chpasswd'
    echo -e "tmsh modify auth user admin shell bash"
    echo -e "tmsh modify /sys db systemauth.disablerootlogin value false;tmsh save sys config\n"

    echo -e "---------- SSH KEY EXCHANGES BIG-IPs -----------\n"
    read -p "Continue (Y/N) (Default=N):" answer
    if [[  $answer == "Y" ]]; then
        for ((i=1; i <= ${#ip[@]}; i++)); do
            echo -e "\n** ${ip[i]}"
            echo -e "- root user:"
            sshpass -p default ssh-copy-id -o StrictHostKeyChecking=no root@${ip[i]}
            echo -e "- admin user:"
            sshpass -p admin ssh-copy-id -o StrictHostKeyChecking=no admin@${ip[i]}
        done
    fi

    echo -e "---------- INCREASE PARTITION SIZE -----------\n"
    for ((i=1; i <= ${#ip[@]}; i++)); do
        echo -e "** ${ip[i]}"
        ssh -o StrictHostKeyChecking=no root@${ip[i]} tmsh show /sys disk directory
        read -p "Continue with partition resize (Y/N) (Default=N):" answer
        if [[  $answer == "Y" ]]; then
            # https://support.f5.com/csp/article/K14952
            ssh -o StrictHostKeyChecking=no root@${ip[i]} tmsh modify /sys disk directory /shared new-size 20971520
            ssh -o StrictHostKeyChecking=no root@${ip[i]} tmsh modify /sys disk directory /appdata new-size 58003456
            ssh -o StrictHostKeyChecking=no root@${ip[i]} tmsh save /sys config
            echo -e "reboot?"
            [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
            ssh -o StrictHostKeyChecking=no root@${ip[i]} reboot
        fi
    done

    echo -e "\n---------- INITIAL SETUP BIG-IQs -----------\n"
    echo -e "\nRun on both BIG-IQ CM and DCD:\n"
    echo -e "For root: tmsh modify auth password (set default)"
    echo -e "For admin: tmsh modify auth user admin password admin"
    echo -e "tmsh modify auth user admin shell bash; tmsh save sys config\n"

    echo -e "---------- SSH KEY EXCHANGES BIG-IQs -----------\n"
    read -p "Continue (Y/N) (Default=N):" answer
    if [[  $answer == "Y" ]]; then
        sshpass -p admin ssh-copy-id -o StrictHostKeyChecking=no admin@10.1.1.4
        sshpass -p admin ssh-copy-id -o StrictHostKeyChecking=no admin@10.1.1.6
    fi

elif [[ "$1" = "restore" ]]; then
    echo -e "\n---------- RESTORE BIG-IPs -----------\n"
    
    for ((i=1; i <= ${#ip[@]}; i++)); do
        echo -e "\n** ${ip[i]}\n"
        read -p "Continue (Y/N) (Default=N):" answer
        if [[  $answer == "Y" ]]; then
            scp -o StrictHostKeyChecking=no ucs/${name[i]}-$d.ucs root@${ip[i]}:/var/local/ucs
        fi
    done

    for ((i=1; i <= ${#ip[@]}; i++)); do 
        echo -e "** ${ip[i]} - ${name[i]}\n"
        read -p "Continue (Y/N) (Default=N):" answer
        if [[  $answer == "Y" ]]; then
            ssh -o StrictHostKeyChecking=no root@${ip[i]} tmsh load /sys ucs /var/local/ucs/${name[i]}-$d.ucs
        fi
    done

    echo -e "\nAfter restore, go manually re-activate the license: (https://support.f5.com/csp/article/K2595)\n"
    echo -e "get_dossier -b ABCDE-ABCDE-ABCDE-ABCDE-ABCDEFG"
    echo -e "vi /config/bigip.license"
    echo -e "reloadlic"

    echo -e "\nFor BIG-IP Cluster: tmsh run cm config-sync force-full-load-push to-group datasync-global-dg"

    echo -e "\nAfter the restore, check UDF SSH connectivity with all BIG-IPs/BIG-IQs."

    ## Add there things to do manually
    echo -e "\nPost-Checks:
    - Connect to each BIG-IP and check state is ONLINE and there are no problem with loading the configuration and license
    - Onboard BIG-IQ CM and DCD using scripts under ./f5-ansible-bigiq-onboarding (edit hosts file to only select cm-1 and dcd-1)
    - Connect to BIG-IQ CM and DCD and make sure it's onboarded correctly
    - Upgrade BIG-IQ to the latest version or version needed
    - Restore UCS on BIG-IQ CM and DCD using UI (https://support.f5.com/csp/article/K45246805)
    - Import BIG-IPs to BIG-IQ"
fi