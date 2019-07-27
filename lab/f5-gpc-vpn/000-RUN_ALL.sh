#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x
# Uncomment set command below for code debugging ansible
#DEBUG_arg="-vvvv"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function pause(){
   read -p "$*"
}

cd /home/f5/f5-gcp-vpn

getPublicIP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
if [[ ! -z $getPublicIP ]]; then
    sed -i "s/0.0.0.0/$getPublicIP/g" ./config.yml
fi

c1=$(grep CUSTOMER_GATEWAY_IP ./config.yml | grep '0.0.0.0' | wc -l)
c2=$(grep '<name>' ./config.yml | wc -l)
PREFIX="$(head -40 config.yml | grep PREFIX | awk '{ print $2}')"
MGT_NETWORK_UDF="$(cat config.yml | grep MGT_NETWORK_UDF | awk '{print $2}')"

if [[ $c1  == 1 || $c2  == 1 ]]; then
       echo -e "${RED}\nPlease, edit config.yml to configure:\n - Credentials\n - Azure Location\n - Prefix (optional)"
	   echo -e "\nOption to run the script:\n\n# nohup ./000-RUN_ALL.sh <ssg/do/vpn> & (the script will be executed with no breaks between the steps)${NC}\n\n"
       exit 1
fi

clear

echo -e "${BLUE}EXPECTED TIME: ~45 min${NC}\n"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
./01-install_azure_cli.sh

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
./02-create-vpn-azure_cli.sh

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
./03-configure-bigip.sh
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# WA Tunnel
sleep 20
./wa_azure_vpn_down_bigip.sh

echo -e "\n${GREEN}If the VPN is not UP, check the BIG-IP logs:\n\n${RED}# ssh admin@$MGT_NETWORK_UDF tail -100 /var/log/ipsec.log${NC}\nYou can also run ./wa_azure_vpn_down_bigip.sh\n"

echo -e "${GREEN}Note: check if the VPN is up ${RED}# ./check_vpn_azure..sh${NC}"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\nPLAYBOOK COMPLETED, DO NOT FORGET TO TEAR DOWN EVERYTHING AT THE END OF YOUR DEMO\n\n${RED}# ./111-DELETE_ALL.sh\n\n or\n\n# nohup ./111-DELETE_ALL.sh &\n\n"
echo -e "/!\ The objects created in Azure will be automatically delete 23h after the deployment was started. /!\ "

echo -e "\n${GREEN}\ If you stop your deployment, the Customer Gateway public IP address will change (SEA-vBIGIP01.termmarc.com's public IP).\nRun the 111-DELETE_ALL.sh script and start a new fresh UDF deployment.${NC}\n\n"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

exit 0