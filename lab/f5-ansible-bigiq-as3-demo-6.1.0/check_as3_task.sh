#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

bigiq="$1"
adminpassword="$2"
id="$3"

clear

echo -e "\nTaskid:${RED} $id ${NC} - BIG-IQ:${RED} $bigiq ${NC}\n"

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}\n"

# SECONDS used for total execution time (see end of the script)
SECONDS=0
message=$(curl -s -k -u admin:$adminpassword https://$bigiq/mgmt/shared/appsvcs/task/$id | jq .results | jq .[].message)
# removing double quotes
message=${message:1:${#message}-2}
echo $message
while [ "$message" == "in progress" ]
do
  message=$(curl -s -k -u admin:$adminpassword https://$bigiq/mgmt/shared/appsvcs/task/$id | jq .results | jq .[].message)
  # removing double quotes
  message=${message:1:${#message}-2}
  echo $message
  sleep 2
done
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"
# total script execution time
echo -e "\nElapsed time:${RED} $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec${NC}\n"
