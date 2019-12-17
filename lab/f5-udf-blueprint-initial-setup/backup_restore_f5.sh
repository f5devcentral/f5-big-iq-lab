#!/bin/bash

#set -x

function pause(){
   read -p "$*"
}

iq_lamp="10.1.1.5"

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

iq_cm="10.1.1.4"
iq_dcd="10.1.1.6"

d=$2

if [[ -z $1 ]]; then
    echo -e "\nOPTIONS: \n[sshkeys] [admin_password] [root_password]\n[backup]\n[restore] [date - option along with restore only]\n[resizedisk]\n"
    ls -lrth ./ucs | grep ucs

elif [[ "$1" = "backup" ]]; then
    echo -e "\n---------- BACKUP BIG-IPs -----------\n"
    for ((i=1; i <= ${#ip[@]}; i++)); do 
        echo -e "** ${ip[i]} - ${name[i]}\n"
        ssh -o StrictHostKeyChecking=no root@${ip[i]} tmsh save sys ucs ${name[i]}-$(date +%m%d%y)
    done

    rm -rf ./ucs
    mkdir ucs

    for ((i=1; i <= ${#ip[@]}; i++)); do 
        scp -o StrictHostKeyChecking=no root@${ip[i]}:/var/local/ucs/${name[i]}-$(date +%m%d%y).ucs ucs
    done

elif [[ "$1" = "sshkeys" ]]; then

    echo -e "\n---------- INITIAL SETUP BIG-IPs -----------\n"

    echo -e "\nRun on all BIG-IPs as root:\n"
    echo -e 'echo "root:default" | chpasswd'
    echo -e 'echo "admin:admin" | chpasswd'
    echo -e "tmsh modify auth user admin shell bash"
    echo -e "tmsh modify /sys db systemauth.disablerootlogin value false"
    echo -e "tmsh save sys config\n"

    echo -e "---------- SSH KEY EXCHANGES BIG-IPs -----------\n"
    read -p "Continue (Y/N) (Default=N):" answer
    if [[  $answer == "Y" ]]; then
        if [[ -z $2 ]]; then
            admin_password="admin"
        else
            admin_password="$2"
        fi
        if [[ -z $3 ]]; then
            root_password="default"
        else
            root_password="$2"
        fi
        
        for ((i=1; i <= ${#ip[@]}; i++)); do
            echo -e "\n** ${ip[i]}"
            ssh-keygen -R "${ip[i]}"
            echo -e "- root user:"
            sshpass -p "$root_password" ssh-copy-id -o StrictHostKeyChecking=no root@${ip[i]}
            echo -e "- admin user:"
            sshpass -p "$admin_password" ssh-copy-id -o StrictHostKeyChecking=no admin@${ip[i]}
        done
    fi

    echo -e "\n---------- INITIAL SETUP BIG-IQs -----------\n"
    echo -e "\nRun on both BIG-IQ CM and DCD as root:\n"
    echo -e "tmsh modify auth password (set default)"
    echo -e "tmsh modify auth user admin password admin"
    echo -e "tmsh modify /sys db systemauth.disablerootlogin value false"
    echo -e "tmsh modify auth user admin shell bash"
    echo -e "tmsh save sys config\n"

    echo -e "---------- SSH KEY EXCHANGES BIG-IQs -----------\n"
    read -p "Continue (Y/N) (Default=N):" answer
    if [[  $answer == "Y" ]]; then
        ssh-keygen -R "$iq_cm"
        ssh-keygen -R "$iq_dcd"
        sshpass -p admin ssh-copy-id -o StrictHostKeyChecking=no admin@$iq_cm
        sshpass -p admin ssh-copy-id -o StrictHostKeyChecking=no admin@$iq_dcd
    fi

elif [[ "$1" = "resizedisk" ]]; then

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
            # Enable iApps  ››  Package Management LX in BIG-IP UI
            ssh -o StrictHostKeyChecking=no root@${ip[i]} touch /var/config/rest/iapps/enable
        fi
    done

    echo -e "\nAfter restore, go manually re-activate the license: (https://support.f5.com/csp/article/K2595)\n"
    echo -e "get_dossier -b ABCDE-ABCDE-ABCDE-ABCDE-ABCDEFG"
    echo -e "vi /config/bigip.license"
    echo -e "reloadlic"

    echo -e "\nFor BIG-IP Cluster: tmsh run cm config-sync force-full-load-push to-group datasync-global-dg"

    echo -e "\nApply https://support.f5.com/csp/article/K45728203 to address hostname issue in AWS."

    echo -e "\nAfter the restore, check UDF SSH connectivity with all BIG-IPs/BIG-IQs."

fi

## Add there things to do manually
echo -e "\nPost-Checks:
- Connect to each BIG-IP and check state is ONLINE and there are no problem with loading the configuration and license
- Check GTM https://support.f5.com/csp/article/K25311653
- Check SSH connection without password using ssh keys (chown root:webusers /etc/ssh/admin/authorized_keys)
- Onboard BIG-IQ CM and DCD using scripts under ./f5-ansible-bigiq-onboarding (edit hosts file to only select cm-1 and dcd-1)
- Connect to BIG-IQ CM and DCD and make sure it's onboarded correctly
- Upgrade BIG-IQ to the latest version or version needed
- Import default AS3 templates
- Import ASM policies
- Configure Radius Server on BIG-IQ
- Configure LDAP Server on BIG-IQ
- Create Paula, Marco, David, Larry, Paul (radius) and Olivia (local) users
- Add licenses pools examples: byol-pool, byol-pool-perAppVE, byol-pool-utility
- Add example TMSH script: config-sync boston cluster (tmsh run cm config-sync force-full-load-push to-group datasync-global-dg)
- Import BIG-IPs to BIG-IQ
- Create the App Services:
    airport_security:
        AS3 security2_site18_seattle 10.1.10.118 SEA AS3-F5-HTTPS-WAF-external-url-lb-template-big-iq-default-v1 (Paula)
        AS3 security_site16_boston 10.1.10.116 BOS AS3-F5-HTTP-lb-traffic-capture-template-big-iq-default-v1 (Paula)
        AS3 security_fqdn airports.example.com BOS AS3-F5-DNS-FQDN-A-type-template-big-iq-default-v1 (Paula)
    IT_apps
        AS3 inventory_site38httpsBigip121 10.1.10.138 SJC without AS3 template (Paula)
        SC site36.example.com 10.1.10.136 BOS Default-f5-HTTPS-WAF-lb-template (Paula)
        SC site42.example.com 10.1.10.142 SEA Default-f5-HTTP-lb-template (Paul)
    finance_apps
        AS3 conference_site41waf 10.1.10.141 SEA without AS3 template (Paul)
        AS3 mail_side40waf 10.1.10.140 SEA without AS3 template (Paul)
- Test HTTP traffic is showing on BIG-IQ
- Test Access traffic is showing on BIG-IQ
- Test DNS traffic is showing on BIG-IQ (add site36.example.com 443 to Pool and add f5_https_header monitor)
- Test Radius user can connect on BIG-IQ
- Test VMware SSG working using DHCP (only if ESX available)
- Test VMware Ansible playbook
- Test AWS and Azure playbooks\n"