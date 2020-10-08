#!/bin/bash
#set -x

# curl -O https://raw.githubusercontent.com/f5devcentral/f5-big-iq-lab/develop/lab/f5-lab-blueprint-initial-setup/02-setup_bigip_bigiq_lab.sh
# chmod +x /root/02-setup_bigip_bigiq_lab.sh
# ./02-setup_bigip_bigiq_lab.sh

function pause(){
   read -p "$*"
}

iq_lamp="10.1.1.5"

# make sure the ucs files are located under ~/f5-lab-blueprint-initial-setup/ucs

name[1]="SEA-vBIGIP01.termmarc.com"
ip[1]="10.1.1.7"
ucs[1]="backup_udf_20201007_SEA-vBIGIP01.termmarc.com_20201007102710.ucs"

name[2]="BOS-vBIGIP01.termmarc.com"
ip[2]="10.1.1.8"
ucs[1]="backup_udf_20201007_BOS-vBIGIP01.termmarc.com_20201007102710.ucs"

name[3]="BOS-vBIGIP02.termmarc.com"
ip[3]="10.1.1.10"
ucs[1]="backup_udf_20201007_BOS-vBIGIP02.termmarc.com_20201007102710.ucs"

name[4]="PARIS-vBIGIP01.termmarc.com"
ip[4]="10.1.1.13"
ucs[1]="backup_udf_20201007_PARIS-vBIGIP01.termmarc.com_20201007102710.ucs"

name[5]="SJC-vBIGIP01.termmarc.com"
ip[5]="10.1.1.11"
ucs[1]="backup_udf_20201007_SJC-vBIGIP01.termmarc.com_20201007102710.ucs"

iq_cm="10.1.1.4"
ucs_cm="backup_udf_20201007_ip-10-1-1-4.us-west-2.compute.internal_20201007102850.ucs"
iq_dcd="10.1.1.6"
ucs_dcd="backup_udf_20201007_ip-10-1-1-6.us-west-2.compute.internal_20201007102850.ucs"

d=$2

if [[ -z $1 ]]; then
    echo -e "\nSetup BIG-IP, then BIG-IQ for the lab.\n\n"
    echo -e "\nOPTIONS:"
    echo -e "init"
    echo -e "sshkeys [admin_password] [root_password]"
    echo -e "setup"
    echo -e "resizedisk"
    echo -e "ucs"

elif [[ "$1" = "init" ]]; then

    echo -e "\n---------- INITIAL SETUP BIG-IPs -----------\n"
    echo -e "\nRun on all BIG-IPs as root:\n"
    echo -e "tmsh modify auth user admin password"
    echo -e "tmsh modify auth user admin shell bash"
    echo -e "tmsh modify /sys db users.strictpasswords value disable"
    echo -e "tmsh modify /sys db systemauth.disablerootlogin value false"
    echo -e 'echo "root:default" | chpasswd'
    echo -e 'echo "admin:admin" | chpasswd'
    echo -e "tmsh save sys config\n"

    # In case you need to change BIG-IP version so it match the UCS
    # tmsh show sys software status
    # tmsh modify sys db liveinstall.saveconfig value disable
    # tmsh modify sys db liveinstall.moveconfig value disable
    # tmsh install sys software image BIGIP-13.1.3.2-0.0.4.iso volume HD1.2 create-volume reboot
    # tmsh delete sys software volume HD1.1

    echo -e "\n---------- INITIAL SETUP BIG-IQs -----------\n"
    echo -e "\nRun on both BIG-IQ CM and DCD as root:\n"
    echo -e "tmsh modify auth password (set default)"
    echo -e "tmsh modify auth user admin password admin"
    echo -e "tmsh modify /sys db systemauth.disablerootlogin value false"
    echo -e "tmsh modify auth user admin shell bash"
    echo -e "tmsh save sys config\n"

elif [[ "$1" = "sshkeys" ]]; then
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

elif [[ "$1" = "ucs" ]]; then
    echo -e "\n---------- RESTORE BIG-IPs -----------\n"
    # Restore UCS BIG-IP https://support.f5.com/csp/article/K13132
    read -p "Continue (Y/N) (Default=N):" answer
    if [[  $answer == "Y" ]]; then
        for ((i=1; i <= ${#ip[@]}; i++)); do
            echo -e "\n** ${ip[i]} - ${ucs[i]}\n"
            read -p "Continue (Y/N) (Default=N):" answer
            if [[  $answer == "Y" ]]; then
                scp -o StrictHostKeyChecking=no ucs/${ucs[i]} root@${ip[i]}:/var/local/ucs
                [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
                ssh -o StrictHostKeyChecking=no root@${ip[i]} tmsh load /sys ucs /var/local/ucs/${ucs[i]}
                # enable iApps  ››  Package Management LX in BIG-IP UI
                # ssh -o StrictHostKeyChecking=no root@${ip[i]} touch /var/config/rest/iapps/enable
            fi
        done

        echo -e "\nAfter restore, go manually re-activate the license: (https://support.f5.com/csp/article/K2595)\n"
        echo -e "get_dossier -b ABCDE-ABCDE-ABCDE-ABCDE-ABCDEFG"
        echo -e "vi /config/bigip.license"
        echo -e "reloadlic"

        echo -e "\nApply https://support.f5.com/csp/article/K45728203 to address hostname issue in AWS."
    fi

    echo -e "\n---------- RESTORE BIG-IQ CM and DCD -----------\n"
    # Restore UCS BIG-IQ https://support.f5.com/csp/article/K45246805
    read -p "Continue (Y/N) (Default=N):" answer
    if [[  $answer == "Y" ]]; then
        echo -e "\n** $iq_dcd - $ucs_dcd\n"
        read -p "Continue (Y/N) (Default=N):" answer
        if [[  $answer == "Y" ]]; then
            scp -o StrictHostKeyChecking=no ucs/$ucs_dcd root@$iq_dcd:/shared/ucs_backups
            [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
            ssh -o StrictHostKeyChecking=no root@$iq_dcd tmsh load /sys ucs /shared/ucs_backups/$ucs_dcd
            [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
            ssh -o StrictHostKeyChecking=no root@$iq_dcd restart /sys service restjavad
        fi
        echo -e "\n** $iq_cm - $ucs_cm\n"
        read -p "Continue (Y/N) (Default=N):" answer
        if [[  $answer == "Y" ]]; then
            scp -o StrictHostKeyChecking=no ucs/$ucs_cm root@$iq_cm:/shared/ucs_backups
            [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
            ssh -o StrictHostKeyChecking=no root@$iq_cm tmsh load /sys ucs /shared/ucs_backups/$ucs_cm
            [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
            ssh -o StrictHostKeyChecking=no root@$iq_cm restart /sys service restjavad
        fi
    fi

elif [[ "$1" = "setup" ]]; then
    echo -e "\n---------- SETUP BIG-IPs -----------\n"

    # SJC-vBIGIP01.termmarc.com
    # for Silo lab
    ssh -o StrictHostKeyChecking=no root@${ip[5]} tmsh create ltm profile http silo-lab-http-profile { accept-xff disabled insert-xforwarded-for disabled }
    ssh -o StrictHostKeyChecking=no root@${ip[5]} tmsh create ltm virtual vip-silo-lab  { destination 1.2.3.6:http ip-protocol tcp mask 255.255.255.255 profiles add { silo-lab-http-profile } }
    ssh -o StrictHostKeyChecking=no root@${ip[5]} tmsh save sys config
fi

echo -e "\nPost-Checks:
- Reach to F5 Lab team 
  autoscaling, cloudformation, cloudwatch, logs, ec2, elasticloadbalancing, sqs, s3, secretsmanager
- Create routes on BIG-IQ CM and DCD toward AWS and Azure Networks: https://support.f5.com/csp/article/K13833
  172.200.0.0     10.1.10.7       255.255.0.0     UG    0      0        0 internal
  172.100.0.0     10.1.10.7       255.255.0.0     UG    0      0        0 internal

  tmsh create /net route 172.200.0.0/16 gw 10.1.10.7
  tmsh create /net route 172.100.0.0/16 gw 10.1.10.7
  tmsh save sys config
  
- Connect to each BIG-IP and check state is ONLINE and there are no problem with loading the configuration and license
- Check GTM https://support.f5.com/csp/article/K25311653
- Check SSH connection without password using ssh keys (chown root:webusers /etc/ssh/admin/authorized_keys)
- Onboard BIG-IQ CM and DCD using scripts under ./f5-ansible-bigiq-onboarding (edit hosts file to only select cm-1 and dcd-1)
- Connect to BIG-IQ CM and DCD and make sure it's onboarded correctly
- Upgrade BIG-IQ to the latest version or version needed
- Import default AS3 templates
- Import ASM policies
- Configure Radius Server on BIG-IQ: RadiusServer
- Configure LDAP Server on BIG-IQ: serverLdap
- Create Paula, Paul, Marco, David, Larry, Olivia (radius) users
- Create Cutom Application Roles
    Application Creator AS3
        user: olivia
        Allow using AS3 without Template
    Application Creator Cloud
        user: paul
        Allow using AS3 without Template
        AS3-F5-HTTP-lb, AS3-F5-HTTPS-WAF-existing-lb, AS3-F5-TCP-lb
    Application Creator VMware
        user: paula
        Allow using AS3 without Template
        AS3-F5-HTTP-lb, AS3-F5-HTTP-lb-traffic-capture, AS3-F5-HTTPS-WAF-external-url-lb, 
        AS3-F5-FastL4-TCP-lb, AS3-F5-DNS-FQDN-A-type, AS3-F5-TCP-lb-built-in-profile
- Add licenses pools examples:
        byol-pool
        byol-pool-perAppVE
        byol-pool-utility
- Add example TMSH script: config-sync boston cluster (tmsh run cm config-sync force-full-load-push to-group datasync-global-dg)
- Add example iHealth, create schedule report
- Import BIG-IPs to BIG-IQ using using scripts under ./f5-ansible-bigiq-onboarding or manually using the BIG-IQ UI
- Pre-deployed Application Services: (ansible playbooks commands in ~/f5-ansible-bigiq-onboarding/cmd_bigiq_onboard.sh)
    =>>>> LOOK AT description_lab.txt
- Test HTTP traffic is showing on BIG-IQ
- Test Access traffic is showing on BIG-IQ
- Test DNS traffic is showing on BIG-IQ (add site36.example.com 443 to Pool and add f5_https_header monitor)
- Test Radius user can connect on BIG-IQ
- Test VMware SSG working using DHCP (only if ESX available)
- Test VMware Ansible playbook
- Test AWS and Azure playbooks\n"