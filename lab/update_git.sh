#!/bin/bash

##### INSTALLATION
## Configured in /etc/rc.local
## curl -o /home/f5student/update_git.sh https://raw.githubusercontent.com/f5devcentral/f5-big-iq-lab/develop/lab/update_git.sh
## /home/f5student/update_git.sh > /home/f5student/update_git.log
## chown -R f5student:f5student /home/f5student

#################### INFORMATION #################### 

# In order to be able to use the same repo with different BIG-IQ version, I used flat file which are saved in the blueprint.
# bigiq_version_aws
# bigiq_version_azure
# bigiq_version_vmware
# bigiq_version_as3
# those files are save with the proper versions in the blueprint if needed. They will be use to keep the folder according to the release if any
# e.g. if bigiq_version_as3 set to 7.0.0, folder f5-ansible-bigiq-as3-demo-7.0.0 will be renamed to f5-ansible-bigiq-as3-demo
# and f5-ansible-bigiq-as3-demo-6.1.0 will be deleted
# 
# If you need to force a folder to be a specific version different than the default one set in the flat file in the blueprint, edit the file.
# e.g. echo "6.1.0" > ~/bigiq_version_aws

# BEFORE SAVING THE BLUEPRINT, DELETE udf_auto_update_git so new deployment will download the latest version of the lab scripts/tools.
# rm ~/udf_auto_update_git 

#####################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

env="udf"
user="f5student"

echo -e "Environement:${RED} $env ${NC}"

cd /home/$user

if [ -f /home/$user/udf_auto_update_git ]; then
    echo -e "\nIn order to force the scripts/tools updates, delete the file udf_auto_update_git and re-run ./update_git.sh (optional).\n"
else
    # create default BIG-IQ version file
    if [ ! -f /home/$user/bigiq_version_aws ]; then
        echo "6.1.0" > /home/$user/bigiq_version_aws
    fi
    if [ ! -f /home/$user/bigiq_version_azure ]; then
        echo "7.0.0" > /home/$user/bigiq_version_azure
    fi
    if [ ! -f /home/$user/bigiq_version_vmware ]; then
        echo "6.1.0" > /home/$user/bigiq_version_vmware
    fi
    if [ ! -f /home/$user/bigiq_version_as3 ]; then
        echo "7.0.0" > /home/$user/bigiq_version_as3
    fi

    bigiq_version_aws=$(cat /home/$user/bigiq_version_aws)
    bigiq_version_azure=$(cat /home/$user/bigiq_version_azure)
    bigiq_version_vmware=$(cat /home/$user/bigiq_version_vmware)
    bigiq_version_as3=$(cat /home/$user/bigiq_version_as3)

    echo "Cleanup previous files..."
    rm -rf f5-* scripts* crontab* ldap build* > /dev/null 2>&1

    # Reset default GW in case SSLO script is running
    sudo ip route change default via 10.1.1.2 dev eth0

    echo "Install new scripts..."
    git clone https://github.com/f5devcentral/f5-big-iq-lab.git --branch develop
    mv /home/$user/f5-big-iq-lab/lab/* /home/$user

    if [[  $env == "udf" ]]; then
        # remove repo directory only if UDF, keep it for PME lab so people can run the ./containthedocs-cleanbuild.sh to validate lab guide
        rm -rf /home/$user/f5-big-iq-lab
    fi

    echo "AWS scripts"
    mv f5-aws-vpn-ssg-$bigiq_version_aws f5-aws-vpn-ssg > /dev/null 2>&1
    echo "Azure scripts"
    mv f5-azure-vpn-ssg-$bigiq_version_azure f5-azure-vpn-ssg > /dev/null 2>&1
    echo "Vmware scripts"
    mv f5-vmware-ssg-$bigiq_version_vmware f5-vmware-ssg > /dev/null 2>&1
    echo "AS3 playbooks"
    mv f5-ansible-bigiq-as3-demo-$bigiq_version_as3 f5-ansible-bigiq-as3-demo > /dev/null 2>&1

    # cleanup other versions
    rm -rf f5-aws-vpn-ssg-* f5-azure-vpn-ssg-* f5-vmware-ssg-* f5-ansible-bigiq-as3-demo-* > /dev/null 2>&1
    echo "Fixing permissions..."
    chmod +x *py *sh scripts/*sh scripts/*/*sh scripts/*py scripts/*/*py f5-*/*sh f5-*/*py f5-*/*pl > /dev/null 2>&1
    chown -R $user:$user . > /dev/null 2>&1

    # Cleanup Clouds credentials
    rm -fr /home/$user/.aws/*
    rm -fr /home/$user/.azure/*

    echo "Installing new crontab"
    if [ "$(whoami)" == "$user" ]; then
        crontab < crontab.txt
    else
        # as root
        su - $user -c "crontab < crontab.txt"
    fi
 
    touch udf_auto_update_git
    rm -f last_update_*
    touch last_update_$(date +%Y-%m-%d_%H-%M)
fi

# run only when server boots (through /etc/rc.local as root)
currentuser=$(whoami)
if [[  $currentuser == "root" ]]; then
    # Cleanup docker
    docker kill $(docker ps -q)
    docker stop $(docker ps -q)
    docker rm $(docker ps -a -q)
    docker rmi $(docker images -q) -f
    /home/$user/scripts/cleanup-docker.sh

    # Starting docker images
    docker run --restart=always --name=hackazon -d -p 80:80 mutzel/all-in-one-hackazon:postinstall supervisord -n
    docker run --restart=always --name=dvwa -dit -p 8080:80 infoslack/dvwa
    docker run --restart=always --name=f5-hello-world-blue -dit -p 8081:8080 -e NODE='Blue' f5devcentral/f5-hello-world
    docker run --restart=always --name=f5website -dit -p 8082:80 -e F5DEMO_APP=website f5devcentral/f5-demo-httpd
    # ASM Policy Validator
    docker run --restart=unless-stopped --name=app-sec -dit -p 445:8443 artioml/f5-app-sec
    # ASM Brute Force
    docker build /home/$user/scripts/asm-brute-force -t asm-brute-force
    docker run --restart=always --name=asm-brute-force -dit asm-brute-force
    # Splunk (admin insterface listening on port 8000, HTTP Event Collector listening on port 8088)
    # ==> data stored under /opt/splunk/var/lib/splunk
    docker run -d -p 8000:8000 -p 8088:8088 -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_PASSWORD=purple123" --name splunk splunk/splunk:latest
    docker_splunk_id=$(docker ps | grep splunk | awk '{print $1}')
    # wait for splunk to initalize
    sleep 30
    # Splunk enable SSL
    docker exec $docker_splunk_id sudo su -c "sed -i 's/enableSplunkWebSSL = false/enableSplunkWebSSL = true/g' /opt/splunk/etc/system/default/web.conf"
    # Splunk create admin directories
    docker exec $docker_splunk_id sudo su -c "mkdir -p /opt/splunk/etc/users/admin/search/local/data/ui/views"
    docker exec $docker_splunk_id sudo su -c "mkdir -p /opt/splunk/etc/users/admin/user-prefs/local"
    # Splunk create BIG-IQ dashboard
    docker cp splunk/*.xml $docker_splunk_id:/opt/splunk/etc/users/admin/search/local/data/ui/views
    # Splunk set default dashboard for admin user
    docker cp splunk/user-prefs.conf $docker_splunk_id:/opt/splunk/etc/users/admin/user-prefs/local
    # Splunk fix permissions
    docker exec $docker_splunk_id sudo su -c "chown -R splunk:splunk /opt/splunk/etc/users"
    # Splunk create spunlk HTTP Event Collector and enable it
    docker exec $docker_splunk_id sudo su -c "/opt/splunk/bin/splunk http-event-collector create token-big-iq32 -uri https://localhost:8089 -description 'demo splunk' -disabled 0 -index main -indexes main -sourcetype _json -auth admin:purple123"
    docker exec $docker_splunk_id sudo su -c "/opt/splunk/bin/splunk http-event-collector enable -uri https://localhost:8089 -enable-ssl 1 -auth admin:purple123"
    docker exec $docker_splunk_id /opt/splunk/bin/splunk http-event-collector list -uri https://localhost:8089 -auth admin:purple123 | grep 'token=' | awk 'BEGIN { FS="=" } { print $2 }' | tr -dc '[:print:]' > /home/$user/splunk-token
    sleep 5
    docker exec $docker_splunk_id sudo su -c "/opt/splunk/bin/splunk restart"

    # load f5demo.ldif and expose port 389 for LDAP access
    docker run --volume `/home/$user/ldap`/home/$user/ldap:/container/service/slapd/assets/config/bootstrap/ldif/custom \
            -e LDAP_ORGANISATION="F5 Networks" \
            -e LDAP_DOMAIN="f5demo.com" \
            -e LDAP_ADMIN_PASSWORD=ldappass \
            -p 389:389 \
            --name my-openldap-container \
            --detach osixia/openldap:1.2.4 \
            --copy-service

    ldapsearch -x -H ldap://localhost -b dc=f5demo,dc=com -D "cn=admin,dc=f5demo,dc=com" -w ldappass > /home/$user/ldap/f5-ldap.log

    docker_hackazon_id=$(docker ps | grep hackazon | awk '{print $1}')
    docker cp f5-demo-app-troubleshooting/f5_browser_issue.php $docker_hackazon_id:/var/www/hackazon/web
    docker cp f5-demo-app-troubleshooting/f5-logo-black-and-white.png $docker_hackazon_id:/var/www/hackazon/web
    docker cp f5-demo-app-troubleshooting/f5-logo.png $docker_hackazon_id:/var/www/hackazon/web
    docker cp f5-demo-app-troubleshooting/f5_capacity_issue.php $docker_hackazon_id:/var/www/hackazon/web
    docker exec $docker_hackazon_id sh -c "chown -R www-data:www-data /var/www/hackazon/web"

    docker images
    docker ps -a
    docker ps

    # Restart the VM if already created (SSG and VE creation)
    sleep 900 && /home/$user/f5-vmware-ssg/cmd_power_on_vm.sh > /home/$user/f5-vmware-ssg/cmd_power_on_vm.log 2> /dev/null &
    sleep 1100 && sudo chown -R $user:$user /home/$user/f5-vmware-ssg/*.log 2> /dev/null &
    chown -R $user:$user /home/$user
fi

exit 0