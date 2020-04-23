#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x
# Uncomment set command below for code debugging ansible
#DEBUG_arg="-vvvv"

# Default value set to UDF
env="udf"

############################################################################################
# CONFIGURATION
ip_cm1="$(cat hosts | grep cm-1 | awk '{print $2}' | sed 's/ansible_host=//g')"

############################################################################################

function pause(){
   read -p "$*"
}

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "\n${RED}Import detault as3 templates ${NC}"

ssh -o StrictHostKeyChecking=no root@$ip_cm1 <<'ENDSSH'
bash
cd /home/admin;
rm -rf f5-big-iq*.tar.gz f5devcentral-f5-big-iq-*;
curl -k -L https://github.com/f5devcentral/f5-big-iq/tarball/7.1.0 > f5-big-iq.tar.gz;
tar -xzvf f5-big-iq.tar.gz;
cd f5*/f5-appsvcs-templates-big-iq/default/json/;
sed -i 's/"published": false/"published": true/g' *json
for json in *.json; do 
curl -s -k -H "Content-Type: application/json" -X POST -d @$json http://localhost:8100/cm/global/appsvcs-templates ;
sleep 1
done
cd /home/admin;
cd f5*/f5-appsvcs-templates-big-iq/community/json/;
sed -i 's/"published": false/"published": true/g' *json
for json in *.json; do 
curl -s -k -H "Content-Type: application/json" -X POST -d @$json http://localhost:8100/cm/global/appsvcs-templates ;
sleep 1
done
ENDSSH
