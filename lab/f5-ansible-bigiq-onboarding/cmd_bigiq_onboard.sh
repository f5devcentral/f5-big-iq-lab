#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x
# Uncomment set command below for code debugging ansible
#DEBUG_arg="-vvvv"

# Default value set to UDF
if [ -z "$2" ]; then
  env="udf"
else
  #env="sjc"
  #env="sjc2"
  env=$2
fi

############################################################################################
# CONFIGURATION
ip_dcd1="$(cat inventory/group_vars/$env-bigiq-dcd-01.yml| grep bigiq_onboard_server | awk '{print $2}')"
ip_cm1="$(cat inventory/group_vars/$env-bigiq-cm-01.yml| grep bigiq_onboard_server | awk '{print $2}')"

## TO BE REMOVED when bulkDiscovery.pl isn't used anymore
pwd_cm1="$(cat inventory/group_vars/$env-bigiq-dcd-01.yml| grep bigiq_onboard_new_admin_password | awk '{print $2}')"

declare -a ips=("$ip_cm1" "$ip_dcd1")

# F5 INTERNAL LAB ONLY
release="v7.0.0"
#release="v6.1.0"
#release="v6.0.1.1"
############################################################################################

function pause(){
   read -p "$*"
}

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Usage
if [[ -z $1 ]]; then
    echo -e "\nUsage: ${RED} $0 <pause/nopause> [<udf/sjc/sjc2> <build number> <iso>] ${NC}([] = optional)\n"
    exit 1;
fi

# SECONDS used for total execution time (see end of the script)
SECONDS=0

echo -e "\nEnvironement:${RED} $env ${NC}\n"

echo -e "Exchange ssh keys with BIG-IQ & DCD:"
for ip in "${ips[@]}"; do
  echo "$ip"
  sshpass -p default ssh-copy-id -o StrictHostKeyChecking=no -i /home/f5/.ssh/id_rsa.pub root@$ip
done

################################################## ONLY FOR PME LAB START ########################################################
if [[  $env != "udf" ]]; then
  echo -e "\n${RED}INTERNAL USE --- ONLY F5 LAB --- START ${NC}"

  echo -e "\nSET PID IN BACKGROUND:"
  echo -e "1. Stop currently running command: ${RED}Ctrl+Z${NC}"
  echo -e "2. To move stopped process to background execute command: ${RED}bg${NC}"
  echo -e "3. To make sure command will run after you close the ssh session execute command: ${RED}disown -h${NC}"

  if [ -z "$4" ]; then
    echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
    # if no iso specified download the image from build server  
    echo -e "\n${GREEN}Download iso${NC}"
    [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
    ## Cleanup
    rm -f *iso *iso.md5 *iso.md5.verify activeVolume status
    # remove cookie if older than 1 day
    if [[ $(find "./.cookie" -mmin +120 -print 2> /dev/null) ]]; then
      echo -e "${GREEN}Deleted .cookie older than 2 hours"
      rm -f ./.cookie
    fi
    if [ ! -f ./.cookie ]; then
      # Corporate user/password to download the latest iso
      echo -e "${GREEN}Corporate F5 username:${NC}"
      read f5user
      echo -e "${GREEN}Corporate F5 password:${NC}"
      read -s f5pass
    fi
    
    echo -e "\n${GREEN}F5 internal domain:${NC}"
    read f5domain

    # to fix DNS and NTP servers
    sed -i "s/f5.com/$f5domain/g" inventory/group_vars/*
    
    if [[ -z $3 ]]; then
      build="current"
    else
      build="build$3.0"
    fi
    ## download iso file
    curl -k "https://weblogin.$f5domain/sso/login.php?redir=https://nibs.$f5domain/build" -H "Connection: keep-alive" -H "Pragma: no-cache" -H "Cache-Control: no-cache" -H "Origin: https://weblogin.$f5domain" -H "Upgrade-Insecure-Requests: 1" -H "DNT: 1" -H "Content-Type: application/x-www-form-urlencoded" -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" -H "Referer: https://weblogin.$f5domain/sso/login.php?msg=Invalid%20Credentials&redir=https://nibs.$f5domain/build" -H "Accept-Encoding: gzip, deflate, br" -H "Accept-Language: en-US,en;q=0.9,fr-FR;q=0.8,fr;q=0.7" --data "user=$f5user&pass=$f5pass&submit_form=Submit" --compressed -c ./.cookie
    curl -k -b ./.cookie -o - https://nibs.$f5domain/build/bigiq/$release/daily/$build/ | grep BIG-IQ | grep 'iso"'  | awk '{print $6}' | grep -oP '(?<=").*(?=")' > iso.txt
    iso=$(cat iso.txt)
    curl -k -b ./.cookie -o - https://nibs.$f5domain/build/bigiq/$release/daily/$build/$iso > $iso
    curl -k -b ./.cookie -o - https://nibs.$f5domain/build/bigiq/$release/daily/$build/$iso.md5 > $iso.md5
    md5sum $iso > $iso.md5.verify
    DIFF=$(diff $iso.md5.verify $iso.md5) 
    if [[  "$DIFF" != "" ]]; then
        echo -e "The md5 is different."
        cat $iso.md5
        cat $iso.md5.verify
        exit 2;
    else
        echo -e "\nIso is good!\n"
        ls -lrt $iso*
    fi
  else
    # use the iso transfered on the lamp server in parameter 4
    iso=$4
    ls -lrt $iso*
  fi
  
  echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

  if [ -f $iso ]; then
      # loop around the BIG-IQ CM/DCD
      for ip in "${ips[@]}"; do
        # transfer iso image
        echo -e "\n${GREEN}Transfer iso on $ip ${NC}"
        [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
        ssh -o StrictHostKeyChecking=no -o StrictHostKeyChecking=no root@$ip rm -f /shared/images/*.iso
        scp -o StrictHostKeyChecking=no $iso root@$ip:/shared/images/
        echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
        echo -e "\n${GREEN}Install on $ip ${NC}"
        [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
        # check active volume and install
        ssh -o StrictHostKeyChecking=no root@$ip tmsh show sys software status > activeVolume
        activeVolume=$(cat activeVolume | grep yes | awk '{print $1}')
        if [[  $activeVolume == "HD1.1" ]]; then
          ssh -o StrictHostKeyChecking=no root@$ip tmsh delete sys software volume HD1.2
          sleep 10
          ssh -o StrictHostKeyChecking=no root@$ip tmsh modify sys db liveinstall.saveconfig value disable
          sleep 5
          ssh -o StrictHostKeyChecking=no root@$ip tmsh modify sys db liveinstall.moveconfig value disable
          sleep 5
          ssh -o StrictHostKeyChecking=no root@$ip tmsh install sys software image $iso volume HD1.2 create-volume reboot
        else
          ssh -o StrictHostKeyChecking=no root@$ip tmsh delete sys software volume HD1.1
          sleep 10
          ssh -o StrictHostKeyChecking=no root@$ip tmsh modify sys db liveinstall.saveconfig value disable
          sleep 5
          ssh -o StrictHostKeyChecking=no root@$ip tmsh modify sys db liveinstall.moveconfig value disable
          sleep 5
          ssh -o StrictHostKeyChecking=no root@$ip tmsh install sys software image $iso volume HD1.1 create-volume reboot
        fi
      done
      echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
      echo -e "\n${GREEN}Install on going - status $ip ${NC}"
      for ip in "${ips[@]}"; do
        status=""
        while [[ $status != "complete" ]] 
          do
              ssh -o StrictHostKeyChecking=no root@$ip tmsh show sys software status > status
              status=$(cat status | grep no | awk '{print $6}')
              percentage=$(cat status | grep no | awk '{print $7 $8}')
              if [[ $status == "complete" ]]; then
                echo -e "install $ip status =${GREEN} $status $percentage ${NC}"
              else
                echo -e "install $ip status =${RED} $status $percentage ${NC}"
              fi
              sleep 30
          done
      done
  else
    echo -e "$iso does not exist.\nYou may delete the ${RED}./.cookie${NC} file to re-authenticate."
    exit 3;
  fi
  echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"


  echo -e "\n${RED}Waiting 15 min ... ${NC}"
  sleep 900

  echo -e "\n${RED}INTERNAL USE --- ONLY F5 LAB --- END ${NC}"
fi
################################################## ONLY FOR PME LAB END ########################################################

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Install ansible-galaxy roles${NC}"
[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
ansible-galaxy install f5devcentral.bigiq_onboard --force
ansible-galaxy install f5devcentral.register_dcd --force

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Onboarding BIG-IQ CM and DCD${NC}"
[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
if [[  $env == "udf" ]]; then
  ansible-playbook -i inventory/$env-hosts bigiq_onboard.yml $DEBUG_arg
else
  ansible-playbook -i inventory/$env-hosts .bigiq_onboard_$env.yml $DEBUG_arg
fi

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

### CUSTOMIZATION - F5 INTERNAL LAB ONLY BEGIN
[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

# loop around the BIG-IQ CM/DCD
# enable ssh for admin and set-basic-auth on
for ip in "${ips[@]}"; do
  echo -e "\n---- ${RED} $ip ${NC} ----"
  echo -e "tmsh modify auth user admin shell bash and set-basic-auth on"
  ssh -o StrictHostKeyChecking=no root@$ip tmsh modify auth user admin shell bash
  ssh -o StrictHostKeyChecking=no root@$ip set-basic-auth on
done

# disable ssl check for VMware SSG on the CM
ssh -o StrictHostKeyChecking=no root@$ip_cm1 << EOF
  echo >> /var/config/orchestrator/orchestrator.conf
  echo 'VALIDATE_CERTS = "no"' >> /var/config/orchestrator/orchestrator.conf
  bigstart restart gunicorn
EOF
  
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
### CUSTOMIZATION - F5 INTERNAL LAB ONLY END

echo -e "\n${RED}Waiting 2 min ... ${NC}"
sleep 120

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Add & discover BIG-IPs to BIG-IQ CM${NC}"
[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
# Add devices using the old script bulkDiscovery.pl (ONLY FOR BIG-IQ 5.x and 6.0)
#scp -o StrictHostKeyChecking=no -rp bulkDiscovery.pl inventory/$env-bigip.csv root@$ip_cm1:/root
#echo -e "Using bulkDiscovery.pl to add BIG-IP in BIG-IQ."
#ssh root@$ip_cm1 << EOF
#  cd /root
#  perl ./bulkDiscovery.pl -c $env-bigip.csv -l -s -f -q admin:$pwd_cm1
#EOF

## Using Ansible Role (to use for BIG-IQ 6.1 and above)
ansible-galaxy install f5devcentral.f5ansible,master --force
if [[  $env == "udf" ]]; then
  ansible-playbook -i notahost, bigiq_device_discovery.yml $DEBUG_arg
else
  ansible-playbook -i notahost, .bigiq_device_discovery_$env.yml $DEBUG_arg
fi

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# Create apps only for UDF BP
if [[  $env == "udf" ]]; then
  echo -e "\n${GREEN}Create AS3 Applications${NC}"
  [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
  cd ../f5-ansible-bigiq-udf-bp-initial-setup

  # replacing all users by admin as users are not re-created part of the onboarding
  #sed -i 's/auth_bigiq_paula.json/auth_bigiq_admin.json/g' create_default_as3_app_waf_site15_boston.yml
  sed -i 's/auth_bigiq_paul.json/auth_bigiq_admin.json/g' create_default_as3_app_waf_site40_seattle.yml 
  sed -i 's/auth_bigiq_paul.json/auth_bigiq_admin.json/g' create_default_as3_app_waf_site41_seattle.yml
  sed -i 's/auth_bigiq_paula.json/auth_bigiq_admin.json/g' create_default_as3_app_https_site38_sanjose.yml
  sed -i 's/auth_bigiq_paula.json/auth_bigiq_admin.json/g' create_default_as3_app_http_site16_boston.yml
  sed -i 's/auth_bigiq_paula.json/auth_bigiq_admin.json/g' create_default_as3_app_waf_site18_seattle.yml
  sed -i 's/auth_bigiq_paula.json/auth_bigiq_admin.json/g' create_default_as3_app_dns_site16site18_boston.yml 
  sed -i 's/auth_bigiq_paula.json/auth_bigiq_admin.json/g' create_default_global_app_site16_site18_dns_bigiq.yml

  #ansible-playbook -i notahost, create_default_as3_app_waf_site15_boston.yml $DEBUG_arg
  #sleep 15
  ansible-playbook -i notahost, create_default_as3_app_waf_site40_seattle.yml $DEBUG_arg
  sleep 15
  ansible-playbook -i notahost, create_default_as3_app_waf_site41_seattle.yml $DEBUG_arg
  sleep 15
  ansible-playbook -i notahost, create_default_as3_app_https_site38_sanjose.yml $DEBUG_arg
  sleep 15
  # Below apps are for 7.0
  ansible-playbook -i notahost, create_default_as3_app_http_site16_boston.yml $DEBUG_arg
  sleep 15
  ansible-playbook -i notahost, create_default_as3_app_waf_site18_seattle.yml $DEBUG_arg
  sleep 15
  ansible-playbook -i notahost, create_default_as3_app_dns_site16site18_boston.yml $DEBUG_arg
  sleep 15
  ansible-playbook -i notahost, create_default_global_app_site16_site18_dns_bigiq.yml $DEBUG_arg
fi

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# total script execution time
echo -e "$(date +'%Y-%d-%m %H:%M'): elapsed time:${RED} $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec${NC}"