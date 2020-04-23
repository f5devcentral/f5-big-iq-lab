#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PREFIX="$(head -40 config.yml | grep PREFIX | awk '{ print $2}')"
PREFIXVPN="$PREFIX-vpn"
MGT_NETWORK_UDF="$(cat config.yml | grep MGT_NETWORK_UDF | awk '{print $2}')"

USE_TOKEN=$(grep USE_TOKEN ./config.yml | grep yes | wc -l)
AZURE_CLOUD="$(cat config.yml | grep AZURE_CLOUD | awk '{ print $2}')"
SUBSCRIPTION_ID=$(grep SUBSCRIPTION_ID ./config.yml | awk '{ print $2}')
TENANT_ID=$(grep TENANT_ID ./config.yml | awk '{ print $2}')
CLIENT_ID=$(grep CLIENT_ID ./config.yml | awk '{ print $2}')
SERVICE_PRINCIPAL_SECRET=$(grep SERVICE_PRINCIPAL_SECRET ./config.yml | awk '{ print $2}')

echo -e "\n${BLUE}VPN Azure <-> UDF${NC}"

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

echo -e "\n${GREEN}View the VPN gateway${NC}"
az network vnet-gateway show \
  -n VNet1GW \
  -g $PREFIX \
  --output table

#bgpPeeringAddress=$(az network vnet-gateway show -n VNet1GW -g $PREFIX | jq '.bgpSettings.bgpPeeringAddress')
#bgpPeeringAddress=${bgpPeeringAddress:1:${#bgpPeeringAddress}-2}
#echo -e "\nbgpPeeringAddress =${BLUE} $bgpPeeringAddress ${NC}"

echo -e "\n${GREEN}View the public IP address${NC}"
az network public-ip show \
  --name VNet1GWIP \
  --resource-group $PREFIX \
  --output table

publicIpAddress=$(az network public-ip show --name VNet1GWIP --resource-group $PREFIX | jq '.ipAddress')
publicIpAddress=${publicIpAddress:1:${#publicIpAddress}-2}
echo -e "\npublicIpAddress = ${BLUE} $publicIpAddress ${NC}\n"

echo -e "\n${GREEN}Verify the VPN connection${NC}"
az network vpn-connection show --name $PREFIXVPN --resource-group $PREFIX --output table

echo -e "\n(refresh every 30 seconds if not = Connected)"
while [[ $connectionStatus != "Connected" ]] 
do
    connectionStatus=$(az network vpn-connection show --name $PREFIXVPN --resource-group $PREFIX  | jq '.connectionStatus')
    connectionStatus=${connectionStatus:1:${#connectionStatus}-2}
    if [[ $connectionStatus == "Connected" ]]; then
      echo -e "\nconnectionStatus =${GREEN} $connectionStatus ${NC}"
    else
      echo -e "connectionStatus =${RED} $connectionStatus ${NC}"
      echo -e "\n${GREEN}IPsec logs on the BIG-IP SEA-vBIGIP01.termmarc.com${NC}"
      ssh admin@$MGT_NETWORK_UDF tail -5 /var/log/ipsec.log
    fi
    sleep 30
done

#echo -e "\n${GREEN}Verify the BGP peer status${NC}"
#az network vnet-gateway list-bgp-peer-status -g $PREFIX -n VNet1GW

#echo -e "\n${GREEN}Verify the Learned routes${NC}"
#az network vnet-gateway list-learned-routes -g  $PREFIX -n VNet1GW

exit 0
