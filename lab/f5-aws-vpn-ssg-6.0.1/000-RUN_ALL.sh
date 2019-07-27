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

cd /home/f5/f5-aws-vpn-ssg

getPublicIP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
if [[ ! -z $getPublicIP ]]; then
    sed -i "s/0.0.0.0/$getPublicIP/g" ./config.yml
fi

c1=$(grep CUSTOMER_GATEWAY_IP ./config.yml | grep '0.0.0.0' | wc -l)
c3=$(grep '<name_of_the_aws_key>' ./config.yml | wc -l)
c4=$(grep '<key_id>' ./config.yml | wc -l)
PREFIX="$(head -20 config.yml | grep PREFIX | awk '{ print $2}')"
nPREFIX="$(echo $PREFIX | wc -m)"
MGT_NETWORK_UDF="$(cat config.yml | grep MGT_NETWORK_UDF | awk '{print $2}')"
BIGIQ_MGT_HOST="$(cat config.yml | grep BIGIQ_MGT_HOST | awk '{print $2}')"

if [[ $c1 == 1 || $c3 == 1 || $c4 == 1 ]]; then
       echo -e "${RED}\nPlease, edit config.yml to configure:\n - AWS credential\n - AWS Region\n - SSH Key Name\n - Prefix (optional)"
       echo -e "\nOption to run the script:\n\n# ./000-RUN_ALL.sh\n\n or\n\n# nohup ./000-RUN_ALL.sh nopause & (the script will be executed with no breaks between the steps)${NC}\n\n"
       exit 1
fi

if (( $nPREFIX > 11 )); then
       echo -e "${RED}PREFIX must be less or equal 10 characteres (config.yml file) ${NC}\n"
       exit 2
fi

clear

## if any variables are passed to the script ./000-RUN_ALL.sh (e.g. 000-RUN_ALL.sh nopause), no pause will happen during the execution of the script
echo -e "\n${GREEN}Did you subscribed and agreed to the software terms for F5 BIG-IP VE - ALL (BYOL, 1 Boot Location) in AWS Marketplace?\n\n"
echo -e "https://aws.amazon.com/marketplace/pp/B07G5MT2KT\n\n${NC}"

echo -e "${BLUE}EXPECTED TIME: ~45 min${NC}\n"

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
#sudo apt-get install python-setuptools
#sudo easy_install pip
#sudo pip install ansible
#sudo apt-get install sshpass
#sudo ansible-playbook $DEBUG_arg 01a-install-pip.yml
ansible-playbook $DEBUG_arg 01b-install-aws.yml
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 02-vpc-elb.yml
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 03-vpn.yml
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
./03-customerGatewayConfigExport.sh

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
./04a-configure-bigip.sh

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

ansible-playbook $DEBUG_arg 04b-configure-bigip.yml -i inventory/hosts
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\nSleep 10 seconds"
sleep 10

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 05-restart-bigip-services.yml -i inventory/hosts
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\nSleep 20 seconds"
sleep 20

# WA Tunnel
ssh admin@$MGT_NETWORK_UDF tmsh modify net tunnels tunnel aws_conn_tun_1 mtu 1350
ssh admin@$MGT_NETWORK_UDF tmsh modify net tunnels tunnel aws_conn_tun_2 mtu 1350

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 06-ubuntu-apache2.yml
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

#[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

# Not needed, this playbook creates a service catalog template (custom)
#ansible-playbook $DEBUG_arg 07-create-aws-ssg-templates.yml -i inventory/hosts

echo -e "\n${GREEN}Sleep 3 min (to allow some time for the VPN to come up)${NC}"
sleep 180

echo -e "\n${GREEN}VPN status:${NC}\n"
./check_vpn_aws.sh

echo -e "\n${GREEN}IPsec logs on the BIG-IP SEA-vBIGIP01.termmarc.com${NC}"
ssh admin@$MGT_NETWORK_UDF tail -10 /var/log/racoon.log

echo -e "\n${GREEN}If the VPN is not UP, check previous playbooks execution are ALL successfull.\nIf they are, try to restart the ipsec services:\n\n# ansible-playbook -i inventory/hosts 05-restart-bigip-services.yml\n"
echo -e "You can check also the BIG-IP logs:\n\n${RED}# ssh admin@$MGT_NETWORK_UDF tail -100 /var/log/racoon.log${NC}\n\n"

echo -e "${GREEN}Note: check if the VPN is up ${RED}# ./check_vpn_aws.sh${NC}"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

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
echo -e "${GREEN}Check the CFT status by running this script on a separate terminal: ${RED}# ./check_cft_ec2_aws.sh ${NC}"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 08a-create-aws-auto-scaling.yml -i inventory/hosts
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}In order to follow the AWS SSG creation, tail the following logs in BIG-IQ:\n/var/log/restjavad.0.log and /var/log/orchestrator.log${NC}\n"

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

echo -e "\n${GREEN}Sleep 5 min (to allow time for the SSG to come up)${NC}"
sleep 300

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Application Creation: (it will start once AWS SSG creation is completed)\n${NC}"
python 09a-create-aws-waf-app.py

echo -e "${RED}\nIn case the WAF app creation failed with 'Failed to get the module device', you can deploy a app without ASM: # python 09b-create-aws-https-app.py ${NC}"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# add ab in crontab to simulate traffic
echo -e "\n${GREEN}Adding traffic generator in crontab.${NC}"
if [ -f ./cache/$PREFIX/1-vpc.yml ]; then
   ELB_DNS="$(head -10 ./cache/$PREFIX/1-vpc.yml | grep ELB_DNS | awk '{ print $2}' | cut -d '"' -f 2)"
   (crontab -l ; echo "* * * * * /usr/bin/ab -n 100 -c 5 https://$ELB_DNS/" ) | crontab -
   # write in a file to use generate_http_bad_traffic.sh and generate_http_clean_traffic.sh
   echo $ELB_DNS >> /home/f5/scripts/ssg-apps
   echo -e "\nAplication URL:${RED} https://$ELB_DNS"
else
   echo "${RED}Something wrong happen, no ./cache/$PREFIX/1-vpc.yml${NC}"
fi

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}NEXT STEPS ON BIG-IQ:\n\n1. Allow Paul to manage the Application previously created:\n  - Connect as admin in BIG-IQ and go to : System > User Management > Users and select Paul.\n  - Select the Role udf-<yourname>-elb, drag it to the right\n  - Save & Close.\n"

echo -e "2. Allow Paul to use the AWS SSG previously  created:\n  - Connect as admin in BIG-IQ and go to : System > Role Management > Roles and\n  select CUSTOM ROLES > Application Roles > Application Creator AWS role.\n  - Select the Service Scaling Groups udf-<yourname>-aws-ssg, drag it to the right\n  - Save & Close.\n"

echo -e "\nPLAYBOOK COMPLETED, DO NOT FORGET TO TEAR DOWN EVERYTHING AT THE END OF YOUR DEMO\n\n${RED}# ./111-DELETE_ALL.sh\n\n or\n\n# nohup ./111-DELETE_ALL.sh nopause &\n\n"
echo -e "/!\ The objects created in AWS will be automatically delete 23h after the deployment was started. /!\ "

echo -e "\n${GREEN}\ If you stop your deployment, the Customer Gateway public IP address will change (SEA-vBIGIP01.termmarc.com's public IP).\nRun the 111-DELETE_ALL.sh script and start a new fresh UDF deployment.${NC}\n\n"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

exit 0
