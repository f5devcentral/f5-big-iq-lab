#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x

# https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-site-to-site-resource-manager-cli
# https://docs.microsoft.com/en-us/azure/vpn-gateway/bgp-how-to-cli#crossprembgp
# https://support.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/bigip-azure-hybrid-cloud-deployment-how-to.html
# https://devcentral.f5.com/articles/big-ip-to-azure-dynamic-ipsec-tunneling

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PREFIX="$(head -40 config.yml | grep PREFIX | awk '{print $2}')"
PREFIXVPN="$PREFIX-vpn"

VNET_CIDR_BLOCK="$(cat config.yml | grep VNET_CIDR_BLOCK | awk '{ print $2}')"
SUBNET1_CIDR_BLOCK="$(cat config.yml | grep SUBNET1_CIDR_BLOCK | awk '{print $2}')"
SUBNET2_CIDR_BLOCK="$(cat config.yml | grep SUBNET2_CIDR_BLOCK | awk '{print $2}')"
SUBNET3_CIDR_BLOCK="$(cat config.yml | grep SUBNET3_CIDR_BLOCK | awk '{print $2}')"
CUSTOMER_GATEWAY_IP="$(cat config.yml | grep CUSTOMER_GATEWAY_IP | awk '{print $2}')"
EXT_NETWORK_UDF_VPN="$(cat config.yml | grep EXT_NETWORK_UDF_VPN | awk '{print $2}')"
EXT_NETWORK_UDF_PEERING="$(cat config.yml | grep EXT_NETWORK_UDF_PEERING | awk '{print $2}')"
DEFAULT_LOCATION="$(cat config.yml | grep DEFAULT_LOCATION | awk '{print $2}')"
LOCAL_GATEWAY="$(cat config.yml | grep LOCAL_GATEWAY | awk '{print $2}')"
SHARED_KEY="$(cat config.yml | grep SHARED_KEY | awk '{print $2}')"
ASN1="$(cat config.yml | grep ASN1 | awk '{print $2}')"
ASN2="$(cat config.yml | grep ASN2 | awk '{print $2}')"
VNET1="$(cat config.yml | grep VNET1 | awk '{print $2}')"
VNET_SUBNET1="$(cat config.yml | grep VNET_SUBNET1 | awk '{print $2}')"
VNET_SUBNET2="$(cat config.yml | grep VNET_SUBNET2 | awk '{print $2}')"

echo -e "\n${GREEN}Create a resource group${NC}"
az group create --name $PREFIX --location $DEFAULT_LOCATION

echo -e "\n${GREEN}Create a virtual network and subnet 1${NC}"
az network vnet create \
  -n $VNET1 \
  -g $PREFIX \
  -l $DEFAULT_LOCATION \
  --address-prefix $VNET_CIDR_BLOCK \
  --subnet-name $VNET_SUBNET1 \
  --subnet-prefix $SUBNET1_CIDR_BLOCK

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Create subnet 2${NC}"
az network vnet subnet create \
  --vnet-name $VNET1 \
  -n $VNET_SUBNET2 \
  -g $PREFIX \
  --address-prefix $SUBNET2_CIDR_BLOCK

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Add a gateway subnet${NC}"
az network vnet subnet create \
  --vnet-name $VNET1 \
  -n GatewaySubnet \
  -g $PREFIX \
  --address-prefix $SUBNET3_CIDR_BLOCK

echo -e "\n${GREEN}View the subnets${NC}"
az network vnet subnet list -g $PREFIX --vnet-name $VNET1 --output table

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Request a public IP address${NC}"
az network public-ip create \
  -n VNet1GWIP \
  -g $PREFIX \
  --allocation-method Dynamic 

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Create the VPN gateway${NC}"
az network vnet-gateway create \
  -n VNet1GW \
  -l $DEFAULT_LOCATION \
  --public-ip-address VNet1GWIP \
  -g $PREFIX \
  --vnet $VNET1 \
  --gateway-type Vpn \
  --sku VpnGw1 \
  --vpn-type RouteBased \
  --asn $ASN1 \
  --sku HighPerformance \
  --no-wait

echo -e "\n(refresh every 1 min if not = Succeeded) -- Expected time: ${GREEN}~30 min${NC}"
while [[ $provisioningState != "Succeeded" ]] 
do
    provisioningState=$(az network vnet-gateway show -n VNet1GW -g $PREFIX | jq '.ipConfigurations' | jq '.[].provisioningState')
    provisioningState=${provisioningState:1:${#provisioningState}-2}
    if [[ $provisioningState == "Succeeded" ]]; then
      echo -e "provisioningState =${GREEN} $provisioningState ${NC}"
    else
      echo -e "provisioningState =${RED} $provisioningState ${NC}"
    fi
    sleep 60
done

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}View the public IP address${NC}"
az network public-ip show \
  --name VNet1GWIP \
  --resource-group $PREFIX \
  --output table

publicIpAddress=$(az network public-ip show --name VNet1GWIP --resource-group $PREFIX | jq '.ipAddress')
publicIpAddress=${publicIpAddress:1:${#publicIpAddress}-2}
echo -e "\npublicIpAddress = ${BLUE} $publicIpAddress ${NC}"

echo -e "\n${GREEN}View the VPN gateway${NC}"
az network vnet-gateway show \
  -n VNet1GW \
  -g $PREFIX \
  --output table

bgpPeeringAddress=$(az network vnet-gateway show -n VNet1GW -g $PREFIX | jq '.bgpSettings.bgpPeeringAddress')
bgpPeeringAddress=${bgpPeeringAddress:1:${#bgpPeeringAddress}-2}
echo -e "\nbgpPeeringAddress =${BLUE} $bgpPeeringAddress ${NC}"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Create the local network gateway${NC}"
az network local-gateway create \
   --gateway-ip-address $CUSTOMER_GATEWAY_IP \
   --name $LOCAL_GATEWAY \
   --resource-group $PREFIX \
   --local-address-prefixes $EXT_NETWORK_UDF_VPN \
   --bgp-peering-address $EXT_NETWORK_UDF_PEERING \
   --asn $ASN2

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# To modify the local network gateway 'gatewayIpAddress'
# az network local-gateway update --gateway-ip-address $CUSTOMER_GATEWAY_IP --name $LOCAL_GATEWAY --resource-group $PREFIX

echo -e "\n${GREEN}Create the VPN connection${NC} -- Expected time: ${GREEN}~5 min${NC}"
az network vpn-connection create \
    --n $PREFIXVPN \
    --resource-group $PREFIX \
    --vnet-gateway1 VNet1GW \
    -l $DEFAULT_LOCATION \
    --shared-key $SHARED_KEY \
    --local-gateway2 $LOCAL_GATEWAY #\
    #--enable-bgp

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n${GREEN}Verify the VPN connection${NC}"
az network vpn-connection show --name $PREFIXVPN --resource-group $PREFIX --output table

exit 0
