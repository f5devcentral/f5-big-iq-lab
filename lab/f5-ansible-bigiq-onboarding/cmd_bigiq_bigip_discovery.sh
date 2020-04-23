#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x
# Uncomment set command below for code debugging ansible
#DEBUG_arg="-vvvv"

# Default value set to UDF
env="udf"


home="/home/f5/f5-ansible-bigiq-onboarding"

############################################################################################
# CONFIGURATION
ip_cm1="$(cat hosts | grep cm-1 | awk '{print $2}' | sed 's/ansible_host=//g')"

declare -a ips=("$ip_cm1")
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

sudo docker build -t f5-big-iq-onboarding .
sudo docker run -t f5-big-iq-onboarding ansible-playbook --version

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

./ansible_helper ansible-playbook /ansible/bigiq_device_discovery_cluster.yml -i /ansible/hosts $DEBUG_arg
./ansible_helper ansible-playbook /ansible/bigiq_device_discovery_standalone.yml -i /ansible/hosts $DEBUG_arg

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# total script execution time
echo -e "$(date +'%Y-%d-%m %H:%M'): elapsed time:${RED} $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec${NC}"