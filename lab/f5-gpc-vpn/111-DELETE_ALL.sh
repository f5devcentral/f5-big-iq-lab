#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x
# Uncomment set command below for code debuging ansible
#DEBUG_arg="-vvvv"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function pause(){
   read -p "$*"
}

cd /home/f5/f5-azure-vpn-ssg

getPublicIP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
if [[ ! -z $getPublicIP ]]; then
    sed -i "s/$getPublicIP/0.0.0.0/g" ./config.yml
fi

c2=$(grep '<name>' ./config.yml | wc -l)
c4=$(grep '<Subscription Id>' ./config.yml | wc -l)
c5=$(grep '<Tenant Id>' ./config.yml | wc -l)
c6=$(grep '<Client Id>' ./config.yml | wc -l)
c7=$(grep '<Service Principal Secret>' ./config.yml | wc -l)
PREFIX="$(head -40 config.yml | grep PREFIX | awk '{ print $2}')"

USE_TOKEN=$(grep USE_TOKEN ./config.yml | grep yes | wc -l)
AZURE_CLOUD="$(cat config.yml | grep AZURE_CLOUD | awk '{ print $2}')"
SUBSCRIPTION_ID=$(grep SUBSCRIPTION_ID ./config.yml | awk '{ print $2}')
TENANT_ID=$(grep TENANT_ID ./config.yml | awk '{ print $2}')
CLIENT_ID=$(grep CLIENT_ID ./config.yml | awk '{ print $2}')
SERVICE_PRINCIPAL_SECRET=$(grep SERVICE_PRINCIPAL_SECRET ./config.yml | awk '{ print $2}')

MGT_NETWORK_UDF="$(cat config.yml | grep MGT_NETWORK_UDF | awk '{print $2}')"
IPSEC_DESTINATION_ADDRESS1=$(grep IPSEC_DESTINATION_ADDRESS1 ./config.yml | awk '{ print $2}')

if [[ $c2  == 1 || $c4  == 1 || $c5  == 1 || $c6  == 1 || $c7  == 1 ]]; then
       echo -e "${RED}\nNo Azure SSG created, nothing to tear down.\n${NC}"
       exit 1
fi

/usr/bin/wall "/!\ DELETION OF ALL AZURE OBJECTS IN 1 MIN /!\  To stop it: # kill -9 $$" 2> /dev/null

sleep 60

echo -e "\n\n${RED}/!\ DELETION OF ALL AZURE OBJECTS (Application/SSG/VPN/VNET) /!\ ${NC} \n"

clear

echo -e "\n\nEXPECTED TIME: ~25 min\n\n"

echo -e "${BLUE}TIME: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 10-delete-azure-app.yml -i inventory/hosts
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "\n\n${RED}/!\ HAVE YOU DELETED THE APP CREATED ON YOUR SSG FROM BIG-IQ? /!\ \n"
echo -e "IF YOU HAVE NOT, PLEASE DELETE ANY APPLICATION(S) CREATED ON YOUR AZURE SSG BEFORE PROCEEDING ${NC}\n\n"

sleep 300

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 11-delete-azure-ssg-resources.yml -i inventory/hosts
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

sleep 300

# Retry delete in case first one failed
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 11-delete-azure-ssg-resources.yml -i inventory/hosts
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"
python 11-delete-azure-ssg-resources-check.py
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "${RED}/!\ IS YOUR SSG COMPLETLY REMOVED FROM YOUR AZURE ACCOUNT? /!\ \n"
echo -e "MAKE SURE THE AZURE SSG HAS BEEN REMOVED COMPLETLY BEFORE PROCEEDING${NC}\n"

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Set Cloud Name to ${BLUE} $AZURE_CLOUD ${NC}"
az cloud set --name $AZURE_CLOUD

echo -e "\n${GREEN}Login${NC}"
if [[ $USE_TOKEN == 1 ]]; then
  az login
else
  az login --service-principal -u $CLIENT_ID --password $SERVICE_PRINCIPAL_SECRET --tenant $TENANT_ID
  az account set --subscription $SUBSCRIPTION_ID
  az role assignment list --assignee $CLIENT_ID --output table
fi

echo -e "\n${GREEN}Delete resource group${GREEN} $PREFIX ${NC}\n"
az group delete --name $PREFIX --yes

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Cleanup Customer Gateway (Seattle BIG-IP)${NC}\n"
ssh admin@$MGT_NETWORK_UDF tmsh delete net route azure_subnet
ssh admin@$MGT_NETWORK_UDF tmsh delete ltm pool keepalive-vpn-azure 
ssh admin@$MGT_NETWORK_UDF tmsh delete net self $IPSEC_DESTINATION_ADDRESS1
ssh admin@$MGT_NETWORK_UDF tmsh delete net tunnels tunnel tunnel-vpn-azure 
ssh admin@$MGT_NETWORK_UDF tmsh delete net tunnels ipsec profile-vpn-azure 
ssh admin@$MGT_NETWORK_UDF tmsh delete net ipsec ike-peer peer-vpn-azure
ssh admin@$MGT_NETWORK_UDF tmsh delete net ipsec traffic-selector selector-vpn-azure 
ssh admin@$MGT_NETWORK_UDF tmsh delete net ipsec ipsec-policy ipsec-policy-vpn-azure
ssh admin@$MGT_NETWORK_UDF tmsh save sys config

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "Clear cache directory and *retry"
rm -rf *.retry nohup.out

echo -e "\n${RED}/!\ DOUBLE CHECK IN YOUR AZURE ACCOUNT ALL THE RESOURCES CREATED FOR YOUR DEMO HAVE BEEN DELETED  /!\ ${NC}\n"

exit 0
