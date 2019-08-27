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

cd /home/f5/f5-aws-vpn-ssg

# Pre-requisits
#sudo apt-get install python-setuptools
#sudo easy_install pip
#sudo pip install ansible
#sudo apt-get install sshpass
#sudo ansible-playbook $DEBUG_arg 01a-install-pip.yml

# Reset default GW in case SSLO script gets kill in the middle of it
sudo ip route change default via 10.1.1.2 dev eth0

getPublicIP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
if [[ ! -z $getPublicIP ]]; then
    sed -i "s/0.0.0.0/$getPublicIP/g" ./config.yml
fi

# Use UDF Cloud Account (only for AWS)
./01-configure-cloud-udf.sh

c1=$(grep CUSTOMER_GATEWAY_IP ./config.yml | grep '0.0.0.0' | wc -l)
c3=$(grep '<name_of_the_aws_key>' ./config.yml | wc -l)
c4=$(grep '<key_id>' ./config.yml | wc -l)
PREFIX="$(head -25 config.yml | grep PREFIX | awk '{ print $2}')"
nPREFIX="$(echo $PREFIX | wc -m)"
MGT_NETWORK_UDF="$(cat config.yml | grep MGT_NETWORK_UDF | awk '{print $2}')"
BIGIQ_MGT_HOST="$(cat config.yml | grep BIGIQ_MGT_HOST | awk '{print $2}')"
UDF_METADATA_URL="$(cat config.yml | grep UDF_METADATA_URL | awk '{print $2}')"
UDF_CLOUD="$(cat config.yml | grep UDF_CLOUD | awk '{print $2}')"

if [[ $c1 == 1 || $c3 == 1 || $c4 == 1 ]]; then
       echo -e "${RED}\nPlease, edit config.yml to configure:\n - AWS credential\n - AWS Region\n - SSH Key Name\n - Prefix (optional)"
	echo -e "\nOption to run the script:\n\n# ./000-RUN_ALL.sh\n\n or\n\n# nohup ./000-RUN_ALL.sh <ssg/ve/vpn> & (the script will be executed with no breaks between the steps)${NC}\n\n"
       exit 1
fi

if (( $nPREFIX > 11 )); then
       echo -e "${RED}PREFIX must be less or equal 10 characteres (config.yml file) ${NC}\n"
       exit 2
fi

clear

echo -e "\n${GREEN1}Before moving further, subscribed and agreed to the software terms in AWS Marketplace for:"
echo -e "- F5 BIG-IP VE - ALL (BYOL, 1 Boot Location) ${RED}https://aws.amazon.com/marketplace/pp/B07G5MT2KT/${NC}"
echo -e "- F5 BIG-IQ Virtual Edition - (BYOL) ${RED}https://aws.amazon.com/marketplace/pp/B00KIZG6KA/\n\n${NC}"

cloudProvider=$(curl -s http://$UDF_METADATA_URL/cloudAccounts/0 | jq '.provider')
cloudProvider=${cloudProvider:1:${#cloudProvider}-2}
if [[ $cloudProvider == "$UDF_CLOUD" ]]; then
   echo -e "AWS console Credentials:${GREEN} https://console.aws.amazon.com/ ${NC}"
   echo -e "\t- accountId:${GREEN} $(curl -s http://$UDF_METADATA_URL/cloudAccounts/0 | jq .accountId) ${NC}"
   echo -e "\t- consoleUsername:${GREEN} $(curl -s http://$UDF_METADATA_URL/cloudAccounts/0 | jq .consoleUsername) ${NC}"
   echo -e "\t- consolePassword:${GREEN} $(curl -s http://$UDF_METADATA_URL/cloudAccounts/0 | jq .consolePassword) ${NC} \n"
fi

echo -e "\nSET PID IN BACKGROUND:"
echo -e "1. Stop currently running command: ${RED}Ctrl+Z${NC}"
echo -e "2. To move stopped process to background execute command: ${RED}bg${NC}"
echo -e "3. To make sure command will run after you close the ssh session execute command: ${RED}disown -h${NC}\n"

# Force pause to accept the terms under UDF account (to be removed later when terms can be accepted programmatically or by default on the AWS F5 account)
pause "Press [Enter] key to continue... CTRL+C to Cancel"

echo -e "\n${BLUE}EXPECTED TIME: ${RED}~45 min${NC}\n"

## If AWS UDF account is used, no need to run this
if [[ $c3 == 0 || $c4 == 0 ]]; then
       
       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
       ansible-playbook $DEBUG_arg 01b-install-aws-creds.yml
       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
fi



echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 02-vpc-elb.yml

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 03-vpn.yml

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
./03-customerGatewayConfigExport.sh

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
./04a-configure-bigip.sh

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 04b-configure-bigip.yml -i inventory/hosts
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\nSleep 10 seconds"
sleep 10

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 05-restart-bigip-services.yml -i inventory/hosts

echo -e "\nVPN Expected time: ${GREEN}10 min${NC}"

# WA Tunnel
sleep 20
./wa_aws_vpn_down_bigip.sh


echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 06-docker-on-ubuntu-aws.yml > 06-docker-on-ubuntu-aws.log 2>&1 &

./check_vpn_aws.sh

echo -e "\n${GREEN}If the VPN is not UP, check previous playbooks execution are ALL successfull.\nIf they are, try to restart the ipsec services:\n\n${RED}# ansible-playbook -i inventory/hosts 05-restart-bigip-services.yml${NC}\nYou can also run ${RED}./wa_aws_vpn_down_bigip.sh${NC}\n"
echo -e "You can check also the BIG-IP logs:\n\n${RED}# ssh admin@$MGT_NETWORK_UDF tail -100 /var/log/racoon.log${NC}\n\n"

echo -e "${GREEN}Note: check if the VPN is up ${RED}# ./check_vpn_aws.sh${NC}"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo "
#!/bin/bash
echo -e '\nCFT SSG status:'
aws cloudformation describe-stack-events --stack-name $PREFIX-aws-ssg  --query 'StackEvents[*].[ResourceStatus,LogicalResourceId,ResourceType,Timestamp]' --output text |  sort -k4r |  perl -ane 'print if !\$seen{\$F[1]}++'
echo -e '\n\nAuto Scaling Group status:'
aws autoscaling describe-auto-scaling-instances --output text
echo -e '\n\nEC2 status:'
aws ec2 describe-instances --query 'Reservations[].Instances[].[PrivateIpAddress,Tags[?Key==\`Name\`].Value[]]' --output text | sed '\$!N;s/\n/ /'
echo
exit 0" > check_cft_ec2_aws.sh
chmod +x check_cft_ec2_aws.sh
echo -e "${GREEN}Check the CFT status by running this script on a separate terminal: ${RED}# ./check_cft_ec2_aws.sh${NC}"

if [[ $1 == "ve" ]]; then
       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
       ansible-playbook $DEBUG_arg 08b-create-aws-cloud-provider-environment.yml -i inventory/hosts
       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
elif [[ $1 == "ssg" ]]; then
       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
       ansible-playbook $DEBUG_arg 08a-create-aws-auto-scaling.yml -i inventory/hosts

       echo -e "\n${GREEN}In order to follow the AWS SSG creation, tail the following logs in BIG-IQ:\n${RED}/var/log/restjavad.0.log${NC} and ${RED}/var/log/orchestrator.log${NC}\n"
     
       echo -e "\n${GREEN}Sleep 5 min (to allow time for the SSG to come up)${NC}"
       sleep 300

       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

       echo -e "\n${GREEN}Application Creation: (it will start once AWS SSG creation is completed)\n${NC}"
       python 09a-create-aws-waf-app.py

       echo -e "${RED}\nIn case the WAF app creation failed with 'Failed to get the module device', you can deploy a app without ASM: ${RED}# python 09b-create-aws-https-app.py${NC}"
       #python 09b-create-aws-https-app.py

       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

       # add ab in crontab to simulate traffic
       echo -e "\n${GREEN}Adding traffic generator in crontab.${NC}"

       if [ -f ./cache/$PREFIX/1-vpc.yml ]; then
              ELB_DNS="$(head -10 ./cache/$PREFIX/1-vpc.yml | grep ELB_DNS | awk '{ print $2}' | cut -d '"' -f 2)"
              # write in a file to use generate_http_bad_traffic.sh and generate_http_clean_traffic.sh
              echo $ELB_DNS >> /home/f5/scripts/ssg-apps
              echo -e "\nAplication URL:${RED} https://$ELB_DNS"
       else
              echo "${RED}Something wrong happen, no ./cache/$PREFIX/1-vpc.yml${NC}"
       fi

       echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

       echo -e "\n${GREEN}NEXT STEPS ON BIG-IQ:\n\n1. Allow Paul to manage the Application previously created:\n  - Connect as admin in BIG-IQ and go to : System > User Management > Users and select Paul.\n  - Select the Role udf-<yourname>-elb, drag it to the right\n  - Save & Close.\n"

       echo -e "2. Allow Paul to use the AWS SSG previously created:\n  - Connect as admin in BIG-IQ and go to : System > Role Management > Roles and\n  select CUSTOM ROLES > Application Roles > Application Creator AWS role.\n  - Select the Service Scaling Groups udf-<yourname>-aws-ssg, drag it to the right\n  - Save & Close.\n"
else
       echo -e "\nVPN only - no SSG or cloud provider/environement will be created."
fi

echo -e "\nPLAYBOOK COMPLETED, DO NOT FORGET TO TEAR DOWN EVERYTHING AT THE END OF YOUR DEMO\n\n${RED}# nohup ./111-DELETE_ALL.sh &${NC}\n\n"
echo -e "${RED}/!\ The objects created in AWS will be automatically delete 23h after the deployment was started. /!\ "
echo -e "\n/!\ If the UDF Cloud Account is used, the UDF AWS account will be deleted with everything in it when the deployment stops or deleted. /!\ "

echo -e "\n/!\ If you stop your deployment, the Customer Gateway public IP address will change (SEA-vBIGIP01.termmarc.com's public IP).\nRun the ./111-DELETE_ALL.sh script to clean things up (reset CUSTOMER_GATEWAY_IP, PREFIX, AWS CREDS, REGION, AMI) and re-start the script.${NC} \n\n"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# total script execution time
echo -e "$(date +'%Y-%d-%m %H:%M'): elapsed time:${RED} $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec${NC}"

exit 0
