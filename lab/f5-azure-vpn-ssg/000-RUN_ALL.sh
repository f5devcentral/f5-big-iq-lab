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

# Usage
if [[ "$1" != "ssg" && "$1" != "ve" && "$1" != "vpn" ]]; then
    echo -e "\nUsage: ${RED} $0 <ssg/ve/vpn>${NC}\n(ssg and ve include creation of the vpn. If vpn specified, no ssg/ve will be created)\n"
    exit 1;
fi

# SECONDS used for total execution time (see end of the script)
SECONDS=0

cd /home/f5/f5-azure-vpn-ssg

getPublicIP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
if [[ ! -z $getPublicIP ]]; then
    sed -i "s/0.0.0.0/$getPublicIP/g" ./config.yml
fi

c1=$(grep CUSTOMER_GATEWAY_IP ./config.yml | grep '0.0.0.0' | wc -l)
c2=$(grep '<name>' ./config.yml | wc -l)
c4=$(grep '<Subscription Id>' ./config.yml | wc -l)
c5=$(grep '<Tenant Id>' ./config.yml | wc -l)
c6=$(grep '<Client Id>' ./config.yml | wc -l)
c7=$(grep '<Service Principal Secret>' ./config.yml | wc -l)
PREFIX="$(head -40 config.yml | grep PREFIX | awk '{ print $2}')"
nPREFIX="$(echo $PREFIX | wc -m)"
MGT_NETWORK_UDF="$(cat config.yml | grep MGT_NETWORK_UDF | awk '{print $2}')"
APP_FQDN="$PREFIX-azure-ssg-$PREFIX-app-azure-pip"
BIGIQ_MGT_HOST="$(cat config.yml | grep BIGIQ_MGT_HOST | awk '{print $2}')"

if [[ $c1 == 1 || $c2  == 1 || $c4  == 1 || $c5  == 1 || $c6  == 1 || $c7  == 1 ]]; then
       echo -e "${RED}\nPlease, edit config.yml to configure:\n - Credentials\n - Azure Location\n - Prefix (optional)"
       echo -e "\nOption to run the script:\n\n# ./000-RUN_ALL.sh\n\n or\n\n# nohup ./000-RUN_ALL.sh <ssg/ve/vpn> & (the script will be executed with no breaks between the steps)${NC}\n\n"
       exit 1
fi

if (( $nPREFIX > 16 )); then
       echo -e "${RED}PREFIX must be less or equal 15 characteres (config.yml file) ${NC}\n"
       exit 2
fi

clear

echo -e "\n${GREEN}Did you subscribed and agreed to the software terms for 'F5 BIG-IP Virtual Edition - BEST - BYOL' in Azure Marketplace?\n"
echo -e "Enabling Azure Marketplace images for programmatic access:
  - On the Azure portal go to All Services
  - In the General section, click on Marketplace
  - Type in 'F5 BIG-IP Virtual Edition - BEST - BYOL' in the Search Box to filter the items
  - Click on each of the images and do the following
  - Click on the 'Want to deploy programmatically?'  link on the right
  - Click on 'Enable, then Save.'\n\n${NC}"

echo -e "\nSET PID IN BACKGROUND:"
echo -e "1. Stop currently running command: ${RED}Ctrl+Z${NC}"
echo -e "2. To move stopped process to background execute command: ${RED}bg${NC}"
echo -e "3. To make sure command will run after you close the ssh session execute command: ${RED}disown -h${NC}\n"

# Force pause to accept the terms under UDF account (to be removed later when terms can be accepted programmatically or by default on the AWS F5 account)
pause "Press [Enter] key to continue... CTRL+C to Cancel"

echo -e "${BLUE}EXPECTED TIME: ~45 min${NC}\n"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
./01-install_azure_cli.sh

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
./02-create-vpn-azure_cli.sh

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
./03-configure-bigip.sh

# WA Tunnel
sleep 20
./wa_azure_vpn_down_bigip.sh

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
## additional packages needed for this playbook
sudo pip install packaging > /dev/null 2>&1
sudo pip install msrestazure > /dev/null 2>&1
sudo pip install ansible[azure] > /dev/null 2>&1
ansible-playbook $DEBUG_arg 04-docker-on-ubuntu-azure.yml > 04-docker-on-ubuntu-azure.log 2>&1 &
sleep 10
tail -20 04-docker-on-ubuntu-azure.log 
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}If the VPN is not UP, check the BIG-IP logs:\n\n${RED}# ssh admin@$MGT_NETWORK_UDF tail -100 /var/log/ipsec.log${NC}\nYou can also run ./wa_azure_vpn_down_bigip.sh\n"

echo -e "${GREEN}Note: check if the VPN is up ${RED}# ./check_vpn_azure.sh${NC}"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

if [[ $1 == "ve" ]]; then     
       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
       ansible-playbook $DEBUG_arg 08b-create-azure-cloud-provider-environment.yml -i inventory/hosts
       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
elif [[ $1 == "ssg" ]]; then
       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
       ansible-playbook $DEBUG_arg 08a-create-azure-auto-scaling.yml -i inventory/hosts

       echo -e "\n${GREEN}In order to follow the  SSG creation, tail the following logs in BIG-IQ:\n/var/log/restjavad.0.log and /var/log/orchestrator.log${NC}\n"

       echo -e "\n${GREEN}Sleep 5 min (to allow time for the SSG to come up)${NC}"
       sleep 300

       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

       echo -e "\n${GREEN}Application Creation: (it will start once Azure SSG creation is completed)\n${NC}"
       python 09a-create-azure-waf-app.py

       echo -e "${RED}\nIn case the WAF app creation failed with 'Failed to get the module device', you can deploy a app without ASM: # python 09b-create-azure-https-app.py ${NC}"
       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

       # add ab in crontab to simulate traffic
       echo -e "\n${GREEN}Adding traffic generator in crontab.${NC}"

       # Get App FQDN
       appfqdn=$(az network public-ip show --resource-group $PREFIX-azure-ssg --name $APP_FQDN | jq '.dnsSettings.fqdn')
       appfqdn=${appfqdn:1:${#appfqdn}-2}
       # write in a file to use generate_http_bad_traffic.sh and generate_http_clean_traffic.sh
       echo $appfqdn >> /home/f5/traffic-scripts/ssg-apps

       #(crontab -l ; echo "* * * * * /usr/bin/ab -n 100 -c 5 https://$appfqdn/" ) | crontab -
       echo -e "\nAplication URL:${RED} https://$appfqdn"

       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

       echo -e "\n${GREEN}NEXT STEPS ON BIG-IQ:\n\n1. Allow Paul to manage the Application previously created:\n  - Connect as admin in BIG-IQ and go to : System > User Management > Users and select Paul.\n  - Select the Role udf-<yourname>-elb, drag it to the right\n  - Save & Close.\n"

       echo -e "2. Allow Paul to use the  SSG previously  created:\n  - Connect as admin in BIG-IQ and go to : System > Role Management > Roles and\n  select CUSTOM ROLES > Application Roles > Application Creator  role.\n  - Select the Service Scaling Groups udf-<yourname>-azure-ssg, drag it to the right\n  - Save & Close.\n"
else
       echo -e "\nVPN only - no SSG or cloud provider/environement will be created."
fi

echo -e "\nPLAYBOOK COMPLETED, DO NOT FORGET TO TEAR DOWN EVERYTHING AT THE END OF YOUR DEMO\n\n${RED}# nohup ./111-DELETE_ALL.sh &\n\n"
echo -e "/!\ The objects created in  will be automatically delete 23h after the deployment was started. /!\ "

echo -e "\n${GREEN}\ If you stop your deployment, the Customer Gateway public IP address will change (SEA-vBIGIP01.termmarc.com's public IP).\nRun the 111-DELETE_ALL.sh script to clean things up (reset CUSTOMER_GATEWAY_IP, PREFIX) and re-start the script.${NC}\n\n"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# total script execution time
echo -e "$(date +'%Y-%d-%m %H:%M'): elapsed time:${RED} $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec${NC}"

exit 0