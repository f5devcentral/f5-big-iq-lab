#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x

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

echo -e "\nEnvironement:${RED} $env ${NC}"

echo -e "Exchange ssh keys with BIG-IQ & DCD:"
if [[  $env == "udf" ]]; then
  for ip in "${ips[@]}"; do
    echo "$ip"
    sshpass -p purple123 ssh-copy-id -o StrictHostKeyChecking=no -i /home/f5/.ssh/id_rsa.pub root@$ip
  done
fi

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${RED}=>>> clear-rest-storage -d${NC} on both BIG-IQ CM and DCD"

for ip in "${ips[@]}"; do
  echo -e "\n---- ${RED} $ip ${NC} ----"
  [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
  echo "clear-rest-storage"
  ssh -o StrictHostKeyChecking=no root@$ip clear-rest-storage -d
done

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
echo -e "\n${RED}Waiting 5 min ... ${NC}"
sleep 300

for ip in "${ips[@]}"; do
  echo -e "\n---- ${RED} $ip ${NC} ----"
  echo "reboot"
  [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
  ssh -o StrictHostKeyChecking=no root@$ip reboot 
done

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# total script execution time
echo -e "$(date +'%Y-%d-%m %H:%M'): elapsed time:${RED} $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec${NC}"