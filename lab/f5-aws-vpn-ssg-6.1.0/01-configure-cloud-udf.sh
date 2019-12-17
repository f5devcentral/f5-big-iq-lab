#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x
# Uncomment set command below for code debugging ansible
#DEBUG_arg="-vvvv"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

UDF_CLOUD="$(cat config.yml | grep UDF_CLOUD | awk '{print $2}')"
UDF_METADATA_URL_AWS="$(cat config.yml | grep UDF_METADATA_URL_AWS | awk '{print $2}')"
UDF_METADATA_URL_RAVELLO="$(cat config.yml | grep UDF_METADATA_URL_RAVELLO | awk '{print $2}')"
BIGIP_RELEASE="$(cat config.yml | grep BIGIP_RELEASE | awk '{print $2}')"

# Create random number to make the PREFIX uniq
sed -i "s/udf-demo/demo-$((RANDOM%9999))/g" ./config.yml
PREFIX="$(head -25 config.yml | grep PREFIX | awk '{ print $2}')"

type=$(cat /sys/hypervisor/uuid | grep ec2 | wc -l)
if [[  $type == 1 ]]; then
       echo "AWS"
       UDF_METADATA_URL=$UDF_METADATA_URL_AWS
else
       echo "Ravello"
       UDF_METADATA_URL=$UDF_METADATA_URL_RAVELLO
fi
cloudProvider=$(curl -s http://$UDF_METADATA_URL/cloudAccounts/0 | jq '.provider')
cloudProvider=${cloudProvider:1:${#cloudProvider}-2}

if [[ $cloudProvider == "$UDF_CLOUD" ]]; then
      echo -e "\n- UDF Cloud Provider: ${GREEN} $cloudProvider ${NC}"
      
      # Get and set AWS credentials
      apiKey=$(curl -s http://$UDF_METADATA_URL/cloudAccounts/0 | jq '.apiKey')
      apiKey=${apiKey:1:${#apiKey}-2}
      echo -e "- UDF apiKey: ${GREEN} $apiKey ${NC}"
      sed -i "s/<key_id>/$apiKey/g" ./config.yml

      apiSecret=$(curl -s http://$UDF_METADATA_URL/cloudAccounts/0 | jq '.apiSecret')
      apiSecret=${apiSecret:1:${#apiSecret}-2}
      echo -e "- UDF apiSecret: ${GREEN} $apiSecret ${NC}"
      sed -i "s#<key_secret>#$apiSecret#g" ./config.yml

      # Get and set AWS region
      region=$(curl -s http://$UDF_METADATA_URL/cloudAccounts/0 | jq '.regions | .[0]')
      region=${region:1:${#region}-2}
      echo -e "- UDF region: ${GREEN} $region ${NC}\n"
      sed -i "s/us-east-1/$region/g" ./config.yml

      # Configure AWS cli
      echo -e "Run AWS CLI config.\n"
      ansible-playbook $DEBUG_arg 01b-install-aws-creds.yml

      # Create a pair of SSH key
      aws ec2 create-key-pair --key-name $PREFIX-ssh-key
      echo -e "- UDF EC2 SSH Key: ${GREEN} $PREFIX-ssh-key ${NC}"
      sed -i "s/<name_of_the_aws_key>/$PREFIX-ssh-key/g" ./config.yml

      # Get BIG-IP AMI
      wget -q https://raw.githubusercontent.com/F5Networks/f5-aws-cloudformation/master/AMI%20Maps/$BIGIP_RELEASE/cached-byol-region-map.json
      bigipami=$(cat cached-byol-region-map.json | jq ".[\"$region\"].AllOneBootLocation")
      bigipami=${bigipami:1:${#bigipami}-2}

      echo -e "\n- BIG-IP AMI ($BIGIP_RELEASE - AllOneBootLocation):${GREEN} $bigipami ${NC}"
      # ami-58c3d327 is the default value in the config.yml file
      sed -i "s/ami-58c3d327/$bigipami/g" ./config.yml

      echo -e "\n\nAWS console Credentials:${GREEN} https://console.aws.amazon.com/ ${NC}"
      echo -e "\t- accountId:${GREEN} $(curl -s http://$UDF_METADATA_URL/cloudAccounts/0 | jq .accountId) ${NC}"
      echo -e "\t- consoleUsername:${GREEN} $(curl -s http://$UDF_METADATA_URL/cloudAccounts/0 | jq .consoleUsername) ${NC}"
      echo -e "\t- consolePassword:${GREEN} $(curl -s http://$UDF_METADATA_URL/cloudAccounts/0 | jq .consolePassword) ${NC} \n"
else
      echo -e "No UDF Cloud Provider supported in this deployment. Use your own account."
fi

exit 0