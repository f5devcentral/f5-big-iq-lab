#!/bin/bash

name[1]="PARIS-vBIGIP01.termmarc.com"
ip[1]="10.1.1.13"
name[2]="BOS-vBIGIP01.termmarc.com"
ip[2]="10.1.1.8"
name[3]="BOS-vBIGIP02.termmarc.com"
ip[3]="10.1.1.10"
name[4]="SEA-vBIGIP01.termmarc.com"
ip[4]="10.1.1.7"
name[5]="SJC-vBIGIP01.termmarc.com"
ip[5]="10.1.1.11"


if [[ -z $1 ]]; then
    echo -e "option: backup or restore"

elif [[ "$1" = "backup" ]]; then
    echo -e "\nBACKUP\n"
    for ((i=1; i <= ${#ip[@]}; i++)); do 
        echo -e "${ip[i]} - ${name[i]}\n"
        sshpass -p "purple123" ssh -o StrictHostKeyChecking=no root@${ip[i]} tmsh save sys ucs ${name[i]}-$(date +%m%d%y)
    done

    rm -rf ./ucs
    mkdir ucs

    for ((i=1; i <= ${#ip[@]}; i++)); do 
        echo -e "$ip\n"
        sshpass -p "purple123" scp -o StrictHostKeyChecking=no root@${ip[i]}:/var/local/ucs/${name[i]}-$(date +%m%d%y).ucs ucs
    done

elif [[ "$1" = "restore" ]]; then
    echo -e "\nRESTORE\n"
    for ((i=1; i <= ${#ip[@]}; i++)); do
        echo -e "$ip\n"
        sshpass -p "default" scp -o StrictHostKeyChecking=no ucs/${name[i]}-$(date +%m%d%y).ucs root@${ip[i]}:/var/local/ucs
    done

    for ((i=1; i <= ${#ip[@]}; i++)); do 
        echo -e "${ip[i]} - ${name[i]}\n"
        sshpass -p "default" ssh -o StrictHostKeyChecking=no root@${ip[i]} tmsh load /sys ucs /var/local/ucs/${name[i]}-$(date +%m%d%y).ucs
    done

else
    echo -e "option: backup or restore"
fi