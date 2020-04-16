#!/bin/bash

##### INSTALLATION
## Configured in /etc/rc.local
## curl -o /home/f5student/update_git.sh https://raw.githubusercontent.com/f5devcentral/f5-big-iq-lab/develop/lab/update_git.sh
## chmod +x /home/f5student/update_git.sh
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

#####################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

env="udf"
user="f5student"
home="/home/$user"

echo -e "Environement:${RED} $env ${NC}"

type=$(cat /sys/hypervisor/uuid 2>/dev/null | grep ec2 | wc -l)
if [[  $type == 1 ]]; then
    echo "Hypervisor: AWS"
else
    echo "Hypervisor: Ravello"
fi

# run only when server boots (through /etc/rc.local as root)
currentuser=$(whoami)
if [[  $currentuser == "root" ]]; then
    cd $home
    # create default BIG-IQ version file
    if [ ! -f $home/bigiq_version_aws ]; then
        echo "6.1.0" > $home/bigiq_version_aws
    fi
    if [ ! -f $home/bigiq_version_azure ]; then
        echo "7.0.0" > $home/bigiq_version_azure
    fi
    if [ ! -f $home/bigiq_version_vmware ]; then
        echo "6.1.0" > $home/bigiq_version_vmware
    fi
    if [ ! -f $home/bigiq_version_as3 ]; then
        echo "7.0.0" > $home/bigiq_version_as3
    fi

    bigiq_version_aws=$(cat $home/bigiq_version_aws)
    bigiq_version_azure=$(cat $home/bigiq_version_azure)
    bigiq_version_vmware=$(cat $home/bigiq_version_vmware)
    bigiq_version_as3=$(cat $home/bigiq_version_as3)

    checkDNSworks=$(nslookup "github.com" | awk -F':' '/^Address: / { matched = 1 } matched { print $2 }' | xargs)
    if [[ -z "$checkDNSworks" ]]; then
        echo -e "DNS resolution isn't working (cannot clone repo https://github.com/f5devcentral/f5-big-iq-lab)\n- Check default route 10.1.1.2 (udf), route -n\n- Check internet connectivity, ping google.com"
        exit 1
    else
        # DNS and internet connectivity working
        echo "Cleanup previous files..."
        rm -rf f5-* scripts* crontab* ldap build* splunk awx > /dev/null 2>&1

        echo "Install new scripts..."
        # GIT_LFS_SKIP_SMUDGE=1 will skip download files in the LFS (ucs files)
        GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/f5devcentral/f5-big-iq-lab.git --branch develop
        mv $home/f5-big-iq-lab/lab/* $home

        if [[  $env == "udf" ]]; then
            # remove repo directory only if UDF, keep it for PME lab so people can run the ./containthedocs-cleanbuild.sh to validate lab guide
            rm -rf $home/f5-big-iq-lab
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
        
        # create log folder for scripts in cron jobs
        mkdir $home/scripts/logs

        chown -R $user:$user . > /dev/null 2>&1

        # Cleanup Clouds credentials
        rm -fr $home/.aws/*
        rm -fr $home/.azure/*

        echo "Installing new crontab"
        if [ "$(whoami)" == "$user" ]; then
            crontab < crontab.txt
        else
            # as root
            su - $user -c "crontab < crontab.txt"
        fi
    
        rm -f last_update_*
        touch last_update_$(date +%Y-%m-%d_%H-%M)
    fi

    echo -e "\nRestart Radius Server"
    /etc/init.d/freeradius restart
    /etc/init.d/freeradius status

    echo -e "\nRestart DHCP Server"
    /etc/init.d/isc-dhcp-server restart
    /etc/init.d/isc-dhcp-server status
    dhcp-lease-list --lease /var/lib/dhcp/dhcpd.leases

    echo -e "\nNoVNC\n"
    su - f5student -c "/usr/bin/vncserver :1 -geometry 1280x800 -depth 24"
    sleep 5
    ps -ef | grep vnc | grep -v grep

    echo -e "\nwebsockify\n"
    su - f5student -c "/usr/bin/websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 6080 localhost:5901"
    sleep 5
    ps -ef | grep websockify | grep -v grep

    # Cleanup docker
    docker kill $(docker ps -q)
    docker stop $(docker ps -q)
    docker rm $(docker ps -a -q)
    docker rmi $(docker images -q) -f
    $home/scripts/cleanup-docker.sh

    ### Start AWX Compose
    rm -rf ~/.awx
    mkdir -p ~/.awx
    ln -snf $home/awx ~/.awx/awxcompose
    docker-compose -f ~/.awx/awxcompose/docker-compose.yml up -d
    # Configuration at later in the script

    ### Starting other docker web app: Hackazon, DVWA, hello world web apps
    docker run --restart=always --name=hackazon -d -p 80:80 mutzel/all-in-one-hackazon:postinstall supervisord -n
    docker run --restart=always --name=dvwa -dit -p 8080:80 infoslack/dvwa
    docker run --restart=always --name=f5-hello-world-blue -dit -p 8081:8080 -e NODE='Blue' f5devcentral/f5-hello-world
    docker run --restart=always --name=f5website -dit -p 8082:80 -e F5DEMO_APP=website f5devcentral/f5-demo-httpd
    docker run --restart=always --name=nginx -dit -p 8083:80 --cap-add NET_ADMIN nginx
    
    ### Add delay, loss and corruption to the nginx web app
    docker_nginx_id=$(docker ps | grep nginx | awk '{print $1}')
    docker exec $docker_nginx_id apt-get update
    docker exec $docker_nginx_id apt-get install iproute2 iputils-ping net-tools -y
    docker exec $docker_nginx_id tc qdisc change dev eth0 root netem delay 300ms loss 30% corrupt 30%
    
    ### ASM Policy Validator
    docker run --restart=unless-stopped --name=app-sec -dit -p 446:8443 artioml/f5-app-sec
    
    ### ASM Brute Force
    docker build $home/scripts/asm-brute-force -t asm-brute-force
    docker run --restart=always --name=asm-brute-force -dit asm-brute-force
    
    ### Splunk (admin insterface listening on port 8000, HTTP Event Collector listening on port 8088)
    # ==> data stored under /opt/splunk/var/lib/splunk
    docker run -d -p 8000:8000 -p 8088:8088 -e "SPLUNK_START_ARGS=--accept-license" -e "SPLUNK_PASSWORD=purple123" --name splunk splunk/splunk:latest
    docker_splunk_id=$(docker ps | grep splunk | awk '{print $1}')
    # wait for splunk to initalize
    sleep 60
    # Splunk enable SSL
    docker exec $docker_splunk_id sudo -u root sed -i 's/enableSplunkWebSSL = false/enableSplunkWebSSL = true/g' /opt/splunk/etc/system/default/web.conf
    # Splunk create admin directories
    docker exec $docker_splunk_id sudo -u root mkdir -p /opt/splunk/etc/users/admin/search/local/data/ui/views
    docker exec $docker_splunk_id sudo -u root mkdir -p /opt/splunk/etc/users/admin/user-prefs/local
    # Splunk create BIG-IQ dashboard
    docker cp splunk/*.xml $docker_splunk_id:/opt/splunk/etc/users/admin/search/local/data/ui/views
    # Splunk set default dashboard for admin user
    docker cp splunk/user-prefs.conf $docker_splunk_id:/opt/splunk/etc/users/admin/user-prefs/local
    # Splunk fix permissions
    docker exec $docker_splunk_id sudo -u root chown -R splunk:splunk /opt/splunk/etc/users
    # Splunk create spunlk HTTP Event Collector and enable it
    docker exec $docker_splunk_id sudo -u root /opt/splunk/bin/splunk http-event-collector create token-big-iq -uri https://localhost:8089 -description 'demo splunk' -disabled 0 -index main -indexes main -sourcetype _json -auth admin:purple123
    docker exec $docker_splunk_id sudo -u root /opt/splunk/bin/splunk http-event-collector enable -uri https://localhost:8089 -enable-ssl 1 -auth admin:purple123
    docker exec $docker_splunk_id /opt/splunk/bin/splunk http-event-collector list -uri https://localhost:8089 -auth admin:purple123 | grep 'token=' | awk 'BEGIN { FS="=" } { print $2 }' | tr -dc '[:print:]' > $home/splunk-token
    sleep 5
    docker exec $docker_splunk_id sudo -u root /opt/splunk/bin/splunk restart

    ### LDAP: load f5demo.ldif and expose port 389 for LDAP access
    docker run --volume $home/ldap:/container/service/slapd/assets/config/bootstrap/ldif/custom \
            -e LDAP_ORGANISATION="F5 Networks" \
            -e LDAP_DOMAIN="f5demo.com" \
            -e LDAP_ADMIN_PASSWORD=ldappass \
            -p 389:389 \
            --name my-openldap-container \
            --detach osixia/openldap:1.2.4 \
            --copy-service

    ldapsearch -x -H ldap://localhost -b dc=f5demo,dc=com -D "cn=admin,dc=f5demo,dc=com" -w ldappass > $home/ldap/f5-ldap.log

    ### Copy some custom files in hackazon docker for labs
    # App Troubleshooting
    docker_hackazon_id=$(docker ps | grep hackazon | awk '{print $1}')
    docker cp f5-demo-app-troubleshooting/f5_browser_issue.php $docker_hackazon_id:/var/www/hackazon/web
    docker cp f5-demo-app-troubleshooting/f5-logo-black-and-white.png $docker_hackazon_id:/var/www/hackazon/web
    docker cp f5-demo-app-troubleshooting/f5-logo.png $docker_hackazon_id:/var/www/hackazon/web
    docker cp f5-demo-app-troubleshooting/f5_capacity_issue.php $docker_hackazon_id:/var/www/hackazon/web
    # Big files for access lab
    base64 /dev/urandom | head -c 300000000 > grosfichier.html
    docker cp grosfichier.html $docker_hackazon_id:/var/www/hackazon/web
    rm -f grosfichier.html
    docker exec $docker_hackazon_id sh -c "chown -R www-data:www-data /var/www/hackazon/web"

    ### Configure AWX
    tower-cli config host http://localhost:9001
    tower-cli config username admin
    tower-cli config password purple123
    tower-cli config verify_ssl False
    echo "Sleeping 2 min for AWX db to be ready."
    sleep 2m
    tower-cli send ~/.awx/awxcompose/awx_backup.json
    tower-cli send ~/.awx/awxcompose/awx_backup.json

    ### Visual Code https://github.com/cdr/code-server
    docker run --restart=always -d -p 7001:8080 -e PASSWORD="purple123" -v "$home:/home/coder/project" codercom/code-server
    docker_codeserver_id=$(docker ps | grep code-server | awk '{print $1}')
    docker exec $docker_codeserver_id sh -c "sudo apt-get update"
    docker exec $docker_codeserver_id sh -c "sudo apt-get install -y python3 python3-dev python3-pip python3-jmespath"
    docker exec $docker_codeserver_id sh -c "pip3 install ansible"

    docker images
    docker ps -a
    docker ps

    # Restart the VM if already created (SSG and VE creation)
    #sleep 900 && $home/f5-vmware-ssg/cmd_power_on_vm.sh > $home/f5-vmware-ssg/cmd_power_on_vm.log 2> /dev/null &
    #sleep 1100 && sudo chown -R $user:$user $home/f5-vmware-ssg/*.log 2> /dev/null &
    chown -R $user:$user $home

    echo -e "\nStatus Radius Server"
    /etc/init.d/freeradius status

    ### Update BIG-IQ welcome banner
    if [ ! -f /usr/games/fortune ]; then
        apt install fortune -y
    fi
    fortune=$(/usr/games/fortune -s literature | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' | sed 's/"/\\"/g' | sed "s/'/\\'/g")
    echo -e "\n\n$fortune"
    json="{\"message\":\"Welcome to BIG-IQ Lab $(date +"%Y")! \n\n$fortune\n\n\",\"isEnabled\":true}"
    curl -s -k -u "admin:purple123" -H "Content-Type: application/json" -X PUT -d "$json" https://10.1.1.4/mgmt/shared/login-ui-message | jq .

    fortuneInBashrc=$(cat $home/.bashrc | grep "fortune" | wc -l)
    if [[ $fortuneInBashrc == 0 ]]; then
        # Customize ~/.bashrc
        echo "/usr/games/fortune -s literature" >> $home/.bashrc
        echo "echo" >> $home/.bashrc
    fi

    echo -e "\n\nLAMP server initialisation COMPLETED"

else
    echo -e "\nIn order to force the lab scripts updates and re-build ALL docker containers, run ./update_git.sh as root user.\n"
fi

exit 0