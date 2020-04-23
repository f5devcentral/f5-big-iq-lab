#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PREFIX="$(head -40 config.yml | grep PREFIX | awk '{ print $2}')"
MGT_NETWORK_UDF="$(cat config.yml | grep MGT_NETWORK_UDF | awk '{print $2}')"

echo -e "\n${BLUE}VPN AWS <-> UDF${NC}"

connection=0

echo -e "\n(refresh every 30 seconds if not VPN UP >= 1)"
while [ $connection -eq 0 ]
do
    connection=$(aws ec2 describe-vpn-connections --output json  | jq '.VpnConnections' | jq "map(select(.Tags[] | .Value == \"$PREFIX-vpn-cf-stack\"))[] | ." | jq '.VgwTelemetry' | jq '.[].Status' | grep UP | wc -l)
    
    if [ $connection -ge 1 ]; then
      echo -e "\nconnectionStatus =${GREEN} Connected ${NC}"
    else
      echo -e "connectionStatus =${RED} Not Connected ${NC}"
      echo -e "\n${GREEN}IPsec logs on the BIG-IP SEA-vBIGIP01.termmarc.com${NC}"
      ssh admin@$MGT_NETWORK_UDF tail -5 /var/log/racoon.log
    fi
    aws ec2 describe-vpn-connections --output json  | jq '.VpnConnections' | jq "map(select(.Tags[] | .Value == \"$PREFIX-vpn-cf-stack\"))[] | ." | jq '.VgwTelemetry'
    sleep 30
done

exit 0