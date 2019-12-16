#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

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

for ((i=1; i <= ${#ip[@]}; i++)); do 
    echo -e "** ${ip[i]} - ${name[i]}\n"
    ssh -o StrictHostKeyChecking=no root@${ip[i]} tmsh modify /sys global-settings hostname ${name[i]}
    #ssh -o StrictHostKeyChecking=no root@${ip[i]} tmsh save /sys config
done