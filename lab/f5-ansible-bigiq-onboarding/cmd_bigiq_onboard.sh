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
sudo docker build -t f5-ansible-runner .
sudo docker run -t f5-ansible-runner ansible-playbook --version
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
./cmd_bigiq_bigip_discovery.sh

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

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# total script execution time
echo -e "$(date +'%Y-%d-%m %H:%M'): elapsed time:${RED} $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec${NC}"