#!/bin/bash

##### INSTALLATION
## Configured in /etc/rc.local
## curl -o /home/f5student/update_git.sh https://raw.githubusercontent.com/f5devcentral/f5-big-iq-lab/develop/lab/update_git.sh
## chmod +x /home/f5student/update_git.sh
## /home/f5student/update_git.sh > /home/f5student/update_git.log 2>&1 &
## chown -R f5student:f5student /home/f5student

# SECONDS used for total execution time (see end of the script)
SECONDS=0

env="udf"
user="f5student"
home="/home/$user"
jumphostIp="10.1.1.5"

echo -e "Environement: $env"

type=$(cat /sys/hypervisor/uuid 2>/dev/null | grep ec2 | wc -l)
if [[  $type == 1 ]]; then
    echo "Hypervisor: AWS"
else
    echo "Hypervisor: UDF Hypervisor or others"
fi

# run only when server boots (through /etc/rc.local as root)
currentuser=$(whoami)
if [[  $currentuser == "root" ]]; then
    cd $home

    checkDNSworks=$(nslookup "github.com" | awk -F':' '/^Address: / { matched = 1 } matched { print $2 }' | xargs)
    if [[ -z "$checkDNSworks" ]]; then
        echo -e "DNS resolution isn't working (cannot clone repo https://github.com/f5devcentral/f5-big-iq-lab)\n- Check default route 10.1.1.2 (udf), route -n\n- Check internet connectivity, ping google.com"
        exit 1
    else
        # DNS and internet connectivity working

        #Cleanup docker
        docker stop $(docker ps -q)
        docker kill $(docker ps -q)
        docker rm $(docker ps -a -q)
        #docker rmi $(docker images -q) -f
        #$home/tools/cleanup-docker.sh

        echo "Cleanup previous files..."
        rm -rf f5-* tools traffic-scripts scripts crontab.txt bigiq_version* build* mywebapp splunk-token
        rm -rf arcadia  gitlab ldap locust radius hoppscotch
        rm -rf awx splunk
        ls -lrt

        echo "Install new scripts..."
        git clone https://github.com/f5devcentral/f5-big-iq-lab.git --branch develop
        mv $home/f5-big-iq-lab/lab/* $home

        if [[  $env == "udf" ]]; then
            # remove repo directory only if UDF, keep it for PME lab so people can run the ./containthedocs-cleanbuild.sh to validate lab guide
            rm -rf $home/f5-big-iq-lab
        fi

        echo "Fixing permissions..."
        chmod +x *sh tools/*sh traffic-scripts/*sh traffic-scripts/*/*sh traffic-scripts/*/*py traffic-scripts/*/*/*py f5-*/*sh f5-*/*py
        
        # create log folder for scripts in cron jobs
        mkdir $home/traffic-scripts/logs
        mkdir $home/tools/logs

        chown -R $user:$user .

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

    echo "Check/Restart RDP"
    su - f5student -c "$home/tools/services_monitor.sh"

    # Radius
    echo -e "\Radius"
    RADIUS_HOME="$home/radius" docker-compose -f $home/radius/docker-compose.yml up -d
    radtest david david $jumphostIp 1812 default

    # Chrome https://github.com/TekFik/chrome-web
    docker run --restart=always -dit --name=chrome --privileged -p 6080:3000 -v $home/chrome:/home/app/config tekfik/chrome
    sleep 5
    docker exec chrome cp /home/app/config/Bookmarks /home/app/.config/google-chrome/Default/
    docker exec chrome cp /home/app/config/Preferences /home/app/.config/google-chrome/Default/
    docker exec chrome pkill -f chrome
    docker exec chrome ps -ef

    ### Start Ansible Tower/AWX Compose
    echo -e "AWX start\n"
    rm -rf ~/.awx
    mkdir -p ~/.awx
    ln -snf $home/awx ~/.awx/awxcompose
    docker-compose -f ~/.awx/awxcompose/docker-compose.yml up -d
    # Configuration done later in the script

    ### Starting other docker web app: Hackazon, DVWA, hello world web apps
    echo -e "Start Web Apps Backend Servers\n"
    docker run --restart=always --name=hackazon -d -p 80:80 mutzel/all-in-one-hackazon:postinstall supervisord -n
    docker run --restart=always --name=dvwa -dit -p 8080:80 infoslack/dvwa
    docker run --restart=always --name=f5-hello-world-blue -dit -p 8081:8080 -e NODE='Blue' f5devcentral/f5-hello-world
    docker run --restart=always --name=f5website -dit -p 8082:80 -e F5DEMO_APP=website f5devcentral/f5-demo-httpd
    docker run --restart=always --name=nginx -dit -p 8083:80 --cap-add NET_ADMIN nginx
    
    echo "Juice Shop - https://owasp.org/www-project-juice-shop/"
    docker run --restart=always --name=juice-shop -dit -p 8085:3000 bkimminich/juice-shop

    ### Starting Arcadia Finance https://gitlab.com/MattDierick/arcadia-finance
    echo -e "Start Arcadia Finance apps\n"
    docker network create internal
    docker run --restart=always -dit --name=mainapp -h mainapp --net=internal registry.gitlab.com/mattdierick/arcadia-finance/mainapp:latest
    docker run --restart=always -dit --name=backend -h backend --net=internal registry.gitlab.com/mattdierick/arcadia-finance/backend:latest
    docker run --restart=always -dit --name=app2 -h app2 --net=internal registry.gitlab.com/mattdierick/arcadia-finance/app2:latest
    docker run --restart=always -dit --name=app3 -h app3 --net=internal registry.gitlab.com/mattdierick/arcadia-finance/app3:latest
    docker run --restart=always -dit -p 8084:80 --name=arcadia -h arcadia --net=internal -v $home/arcadia/default.conf:/etc/nginx/conf.d/default.conf registry.gitlab.com/mattdierick/arcadia-finance/nginx_oss:latest

    # FTP server
    mkdir /tmp/ftp
    chmod 777 /tmp/ftp
    docker run --restart=always -dit -p 21:21 -p 21000-21010:21000-21010 -e USERS="ftpuser|ftpuser|/tmp/ftp" -v /tmp/ftp:/tmp/ftp  -e ADDRESS=10.1.20.110 --name ftp-server delfer/alpine-ftp-server

    ### Add delay, loss and corruption to the nginx web app
    echo -e "Customized Nginx container\n"
    docker exec nginx apt-get update
    docker exec nginx apt-get install iproute2 iputils-ping net-tools -y
    docker exec nginx tc qdisc add dev eth0 root netem delay 300ms loss 30% corrupt 30%
    
    ### ASM Policy Validator
    #echo -e "ASM Policy Validator\n"
    #docker run --restart=unless-stopped --name=app-sec -dit -p 446:8443 artioml/f5-app-sec
    
    ### ASM Brute Force
    echo -e "Brute Force\n"
    docker build $home/traffic-scripts/asm-brute-force -t asm-brute-force
    docker run --restart=always --name=asm-brute-force -dit asm-brute-force

    ## Load testing tool: https://locust.io
    echo -e "Locust\n"
    docker run --restart=unless-stopped --name=locust -dit -p 8089:8089 -v $home/locust:/mnt/locust locustio/locust -f /mnt/locust/locustfile.py --host http://10.1.10.116
    
    ### Splunk (admin insterface listening on port 8000, HTTP Event Collector listening on port 8088)
    echo -e "\nSplunk begin"
    SPLUNK_HOME="$home/splunk" docker-compose -f $home/splunk/docker-compose.yml up -d
    sleep 30
    docker logs splunk_splunk_1 
    # ==> data stored under /opt/splunk/var/lib/splunk
    # wait for splunk to initalize
    echo "Sleep 1 min for splunk to be ready."
    sleep 1m
    # Splunk create admin directories
    mkdir -p $home/splunk/etc/users/admin/search/local/data/ui/views
    mkdir -p $home/splunk/etc/users/admin/user-prefs/local
    # Splunk create BIG-IQ dashboard
    cp $home/splunk/bigiq_dashboard_splunk.xml $home/splunk/etc/users/admin/search/local/data/ui/views
    # Splunk set default dashboard for admin user
    cp $home/splunk/user-prefs.conf $home/splunk/etc/users/admin/user-prefs/local
    # Splunk create spunlk HTTP Event Collector and enable it
    docker exec splunk_splunk_1 sudo -u root /opt/splunk/bin/splunk http-event-collector create token-big-iq -uri https://localhost:8089 -description 'demo splunk' -disabled 0 -index main -indexes main -sourcetype _json -auth admin:purple123
    docker exec splunk_splunk_1 sudo -u root /opt/splunk/bin/splunk http-event-collector enable -uri https://localhost:8089 -enable-ssl 1 -auth admin:purple123
    docker exec splunk_splunk_1 /opt/splunk/bin/splunk http-event-collector list -uri https://localhost:8089 -auth admin:purple123 | grep 'token=' | awk 'BEGIN { FS="=" } { print $2 }' | tr -dc '[:print:]' > $home/splunk-token
    sleep 5
    docker exec splunk_splunk_1 sudo -u root /opt/splunk/bin/splunk restart
    docker logs splunk_splunk_1 
    echo -e "\nSplunk end"

    ### LDAP: load f5demo.ldif and expose port 389 for LDAP access
    echo -e "\nLdap"
    docker run --volume $home/ldap:/container/service/slapd/assets/config/bootstrap/ldif/custom \
            -e LDAP_ORGANISATION="F5 Networks" \
            -e LDAP_DOMAIN="f5demo.com" \
            -e LDAP_ADMIN_PASSWORD=ldappass \
            -p 389:389 \
            --name my-openldap-container \
            --detach osixia/openldap:1.2.4 \
            --copy-service

    # TACAC+ https://hub.docker.com/r/dchidell/docker-tacacs
    echo -e "\nTacacs"
    docker run --restart=always --name=tacacs -dit -p 49:49 dchidell/docker-tacacs

    ### Copy some custom files in hackazon docker for labs
    echo -e "\nApp Troubleshooting customization begin"
    docker cp f5-demo-app-troubleshooting/f5_browser_issue.php hackazon:/var/www/hackazon/web
    docker cp f5-demo-app-troubleshooting/f5-logo-black-and-white.png hackazon:/var/www/hackazon/web
    docker cp f5-demo-app-troubleshooting/f5-logo.png hackazon:/var/www/hackazon/web
    docker cp f5-demo-app-troubleshooting/f5_capacity_issue.php hackazon:/var/www/hackazon/web
    # Big files for access lab
    base64 /dev/urandom | head -c 300000000 > grosfichier.html
    docker cp grosfichier.html hackazon:/var/www/hackazon/web
    rm -f grosfichier.html
    # fix permissions
    docker exec hackazon sh -c "chown -R www-data:www-data /var/www/hackazon/web"
    echo -e "App Troubleshooting customization end\n"

    ### Configure AWX
    echo -e "AWX continue...\n"
    docker-compose -f ~/.awx/awxcompose/docker-compose.yml up -d
    tower-cli config host http://localhost:9001
    tower-cli config username admin
    tower-cli config password purple123
    tower-cli config verify_ssl False
    echo "Sleep 2 min for AWX db to be ready."
    sleep 2m
    tower-cli send ~/.awx/awxcompose/awx_backup.json
    tower-cli send ~/.awx/awxcompose/awx_backup.json
    echo -e "AWX end\n"

    ### Visual Code https://github.com/cdr/code-server
    docker run --restart=always --name=code-server -d -p 7001:8080 -e PASSWORD="purple123" -v "$home:/home/coder/project" codercom/code-server
    docker exec code-server sh -c "sudo apt-get update"
    docker exec code-server sh -c "sudo apt-get install -y python3 python3-dev python3-pip python3-jmespath"
    docker exec code-server sh -c "pip3 install ansible"
    # Download latest F5 Fast extention
    wget $(curl -s https://api.github.com/repos/DumpySquare/vscode-f5-fast/releases | grep browser_download_url | grep '.vsix' | head -n 1 | cut -d '"' -f 4) 
    docker cp *.vsix code-server:/tmp
    docker exec code-server code-server --install-extension /tmp/$(ls *vsix)
    docker exec code-server code-server --install-extension dawhite.mustache
    docker restart code-server
    rm *.vsix

    ### Ldap connectivity check
    ldapsearch -x -H ldap://localhost -b dc=f5demo,dc=com -D "cn=admin,dc=f5demo,dc=com" -w ldappass > $home/ldap/f5-ldap.log

    docker images
    docker ps -a
    docker ps
    
    chown -R $user:$user $home

    echo -e "\nSamba"
    rm -rf /dcdbackup
    mkdir /dcdbackup
    chown -R nobody:nogroup /dcdbackup
    docker run --restart=always --name=samba -dit -p 445:445 -v /dcdbackup:/mount dperson/samba -n -S -p \
           -w WORKGROUP \
           -u "f5student;purple123" \
           -s "dcdbackup;/mount;yes;no;no;f5student" \
           -g "ntlm auth=yes" \
           -g "client min protocol = NT1" \
           -g "server min protocol = NT1" \
           -g "client ipc min protocol = NT1"

    nmap --script smb-protocols localhost
    smbclient -L $jumphostIp -W WORKGROUP -U f5student%purple123
    echo -e "\nTo test the Samba/CIFS server from BIG-IQ:"
    echo -e "mkdir /tmp/testfolder"
    echo -e "mount.cifs //$jumphostIp/dcdbackup /tmp/testfolder -o user=f5student,password=purple123,domain=WORKGROUP,vers=1.0"
    echo -e "umount /tmp/testfolder"
    echo -e "mount.cifs //$jumphostIp/dcdbackup /tmp/testfolder -o user=f5student,password=purple123,domain=WORKGROUP,vers=2.0"
    echo -e "umount /tmp/testfolder"

    ### Update BIG-IQ welcome banner
    if [ ! -f /usr/games/fortune ]; then
        apt install fortune -y
    fi
    fortune=$(/usr/games/fortune -s literature | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' | sed 's/"/\\"/g' | sed "s/'/\\'/g")
    echo -e "\n\n$fortune"
    json="{\"message\":\"Welcome to BIG-IQ Lab $(date +"%Y")! \n\n$fortune\n\n\",\"isEnabled\":true}"
    curl -s -k -u "admin:purple123" -H "Content-Type: application/json" -X PUT -d "$json" https://10.1.1.4/mgmt/shared/login-ui-message | jq .

    sed -i '/fortune/d' $home/.bashrc
    echo "/usr/games/fortune -s literature;echo" >> $home/.bashrc

    echo "If postman does not open using the link on the desktop, open a terminal and launch it from there.

    # bash
    # postman %U" > $home/Desktop/Postman_README

    echo -e "\n\nLAMP server initialisation COMPLETED"

else
    echo -e "\nIn order to force the lab scripts updates and re-build ALL docker containers, run ./update_git.sh as root user.\n"
fi

# total script execution time
echo -e "$(date +'%Y-%d-%m %H:%M'): elapsed time: $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"

exit 0