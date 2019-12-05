#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x
# Uncomment set command below for code debugging ansible
#DEBUG_arg="-vvvv"

# Default value set to UDF
env="udf"

############################################################################################
# CONFIGURATION
ip_dcd1="$(cat hosts | grep dcd-1 | awk '{print $2}' | sed 's/ansible_host=//g')"
ip_cm1="$(cat hosts | grep cm-1 | awk '{print $2}' | sed 's/ansible_host=//g')"

declare -a ips=("$ip_cm1" "$ip_dcd1")
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
    echo -e "\nUsage: ${RED} $0 ${NC}\n"
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

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Onboard BIG-IQ CM and DCD severs.${NC}"
[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
sudo docker build -t f5-big-iq-onboarding .
sudo docker run -t f5-big-iq-onboarding ansible-playbook --version
./ansible_helper ansible-playbook /ansible/bigiq_onboard.yml -i /ansible/hosts $DEBUG_arg

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
echo -e "\n${GREEN}Customization BIG-IQ CM and DCD severs.${NC}"
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

echo -e "\n${RED}Waiting 2 min ... ${NC}"
sleep 120

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Discover and Import BIG-IPs to BIG-IQ CM.${NC}"
[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
./ansible_helper ansible-playbook /ansible/bigiq_device_discovery.yml -i /ansible/hosts $DEBUG_arg

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Import default AS3 templates${NC}"
[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
ssh -o StrictHostKeyChecking=no root@$ip_cm1 << EOF
  bash
  cd /home/admin;
  rm -rf f5-big-iq*.tar.gz f5devcentral-f5-big-iq-*;
  curl -L https://github.com/f5devcentral/f5-big-iq/tarball/7.0.0 > f5-big-iq.tar.gz;
  tar -xzvf f5-big-iq.tar.gz;
  cd f5*/f5-appsvcs-templates-big-iq/default/json/;
  sed -i 's/"published": false/"published": true/g' *json
  for json in *.json; do 
  curl -s -k -H "Content-Type: application/json" -X POST -d @$json http://localhost:8100/cm/global/appsvcs-templates ;
  done
EOF

echo -e "\n${GREEN}Create AS3 Applications${NC}"
[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

cd ../f5-udf-blueprint-initial-setup

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

cd -

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# total script execution time
echo -e "$(date +'%Y-%d-%m %H:%M'): elapsed time:${RED} $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec${NC}"