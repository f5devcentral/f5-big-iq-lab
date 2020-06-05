#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x
# Uncomment set command below for code debuging ansible
#DEBUG_arg="-vvvv"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PREFIX="$(head -25 config.yml | grep PREFIX | awk '{ print $2}')"
MGT_NETWORK_UDF="$(cat config.yml | grep MGT_NETWORK_UDF | awk '{print $2}')"
BIGIQ_MGT_HOST="$(cat config.yml | grep BIGIQ_MGT_HOST | awk '{print $2}')"
APP_NAME="$PREFIX-app-aws"

function pause(){
   read -p "$*"
}

cd /home/f5/f5-aws-vpn-ssg

getPublicIP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
if [[ ! -z $getPublicIP ]]; then
    sed -i "s/$getPublicIP/0.0.0.0/g" ./config.yml
fi

c2=$(grep '<name>' ./config.yml | wc -l)
c3=$(grep '<name_of_the_aws_key>' ./config.yml | wc -l)
c4=$(grep '<key_id>' ./config.yml | wc -l)

if [[ $c2  == 1 || $c3  == 1 || $c4  == 1 ]]; then
       echo -e "${RED}\nNo AWS SSG created, nothing to tear down.\n${NC}"
       exit 1
fi

/usr/bin/wall "/!\ DELETION OF ALL AWS OBJECTS IN 1 MIN /!\  To stop it: # kill -9 $$" 2> /dev/null

sleep 60

echo -e "\n\n${RED}/!\ DELETION OF ALL AWS OBJECTS (Application/SSG/VPN/VPC) /!\ ${NC} \n"

clear

echo -e "\nSET PID IN BACKGROUND:"
echo -e "1. Stop currently running command: ${RED}Ctrl+Z${NC}"
echo -e "2. To move stopped process to background execute command: ${RED}bg${NC}"
echo -e "3. To make sure command will run after you close the ssh session execute command: ${RED}disown -h${NC}"

echo -e "\n\nEXPECTED TIME: ~25 min\n\n"

echo -e "${BLUE}TIME: $(date +"%H:%M")${NC}"
json="{\"configSetName\":\"$APP_NAME\",\"deploy\":true,\"mode\":\"DELETE\"}"
curl -k -u "admin:purple123" -H "Content-Type: application/json" -X POST -d "$json" https://$BIGIQ_MGT_HOST/mgmt/cm/global/tasks/apply-template
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "\n\n${RED}/!\ HAVE YOU DELETED THE APP CREATED ON YOUR SSG FROM BIG-IQ? /!\ \n"
echo -e "IF YOU HAVE NOT, PLEASE DELETE ANY APPLICATION(S) CREATED ON YOUR AWS SSG BEFORE PROCEEDING ${NC}\n\n"

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 11-delete-aws-ssg-resources.yml -i inventory/hosts
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"
python 11-delete-aws-ssg-resources-check.py
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 12-delete-aws-ssg-resources.yml -i inventory/hosts
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "${RED}/!\ IS YOUR SSG COMPLETLY REMOVED FROM YOUR AWS ACCOUNT? /!\ \n"
echo -e "MAKE SURE THE AWS SSG HAS BEEN REMOVED COMPLETLY BEFORE PROCEEDING${NC}\n"

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 12-teardown-aws-vpn-vpc-ubuntu.yml
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Cleanup Customer Gateway (Seattle BIG-IP)${NC}\n"

IPSEC_DESTINATION_ADDRESSES=$(cat cache/$PREFIX/3-customer_gateway_configuration.xml | awk -F'[<>]' '/<ip_address>/{print $3}' | grep 169)

for ip in ${IPSEC_DESTINATION_ADDRESSES[@]}; do
  echo $ip
  ssh admin@$MGT_NETWORK_UDF tmsh delete net self $ip
done

ssh admin@$MGT_NETWORK_UDF tmsh delete net tunnels tunnel aws_conn_tun_1
ssh admin@$MGT_NETWORK_UDF tmsh delete net tunnels tunnel aws_conn_tun_2
ssh admin@$MGT_NETWORK_UDF tmsh delete net tunnels ipsec aws_conn_tun_1_profile
ssh admin@$MGT_NETWORK_UDF tmsh delete net tunnels ipsec aws_conn_tun_2_profile
ssh admin@$MGT_NETWORK_UDF tmsh delete net ipsec ike-peer aws_vpn_conn_peer_1
ssh admin@$MGT_NETWORK_UDF tmsh delete net ipsec ike-peer aws_vpn_conn_peer_2
ssh admin@$MGT_NETWORK_UDF tmsh delete net ipsec traffic-selector aws_conn_tun_1_selector
ssh admin@$MGT_NETWORK_UDF tmsh delete net ipsec traffic-selector aws_conn_tun_2_selector
ssh admin@$MGT_NETWORK_UDF tmsh delete net ipsec ipsec-policy ipsec-policy-vpn-aws
ssh admin@$MGT_NETWORK_UDF tmsh save sys config

sed -i '/PREFIX/d' config.yml
sed -i '/AWS_ACCESS_KEY_ID/d' config.yml
sed -i '/AWS_SECRET_ACCESS_KEY/d' config.yml
sed -i '/AWS_SSH_KEY/d' config.yml
sed -i '/DEFAULT_REGION/d' config.yml
sed -i '/AWS_AZ_1A/d' config.yml
sed -i '/AWS_AZ_1B/d' config.yml
sed -i '/BYOL_BIGIP_AMI/d' config.yml
sed -i '/CUSTOMER_GATEWAY_IP/d' config.yml

sed -i '1s/^/PREFIX: udf-demo\n/' config.yml
sed -i '1s/^/AWS_ACCESS_KEY_ID: <key_id>\n/' config.yml
sed -i '1s/^/AWS_SECRET_ACCESS_KEY: <key_secret>\n/' config.yml
sed -i '1s/^/AWS_SSH_KEY: <name_of_the_aws_key>\n/' config.yml
sed -i '1s/^/DEFAULT_REGION: us-east-1\n/' config.yml
sed -i '1s/^/AWS_AZ_1A: us-east-1a\n/' config.yml
sed -i '1s/^/AWS_AZ_1B: us-east-1b\n/' config.yml
sed -i '1s/^/BYOL_BIGIP_AMI: "ami-58c3d327"\n/' config.yml
sed -i '1s/^/CUSTOMER_GATEWAY_IP: 0.0.0.0\n/' config.yml
sed -i '1s/^/### Config file reset to defaut\n\n/' config.yml

sed -i '$s/^/SSG_NAME:               "{{PREFIX}}-aws-ssg"\n/' config.yml
sed -i '$s/^/CLOUD_ENVIRONMENT_NAME: "{{PREFIX}}-aws-environment"\n/' config.yml
sed -i '$s/^/CLOUD_PROVIDER_NAME:    "{{PREFIX}}-aws-provider"\n/' config.yml
sed -i '$s/^/DEVICE_TEMPLATE_NAME:   "{{PREFIX}}-aws-device-template"\n/' config.yml
sed -i '$s/^/TEMPLATE_NODE_NAME:     "{{PREFIX}}-aws-service-node"\n/' config.yml
sed -i '$s/^/TEMPLATE_POOL_NAME:     "{{PREFIX}}-aws-pool"\n/' config.yml
sed -i '$s/^/SERVICE_CATALOG_NAME:   "{{PREFIX}}-aws-service-catalog"\n/' config.yml
sed -i '$s/^/LTM_RESOURCE_NAME:      "{{PREFIX}}-aws-resource-name"\n/' config.yml

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "Clear cache directory, *retry and private key"
rm -rf cache *.retry nohup.out $PREFIX-ssh-key.pem

echo -e "\n${RED}/!\ DOUBLE CHECK IN YOUR AWS ACCOUNT ALL THE RESOURCES CREATED FOR YOUR DEMO HAVE BEEN DELETED  /!\ ${NC}\n"

exit 0
