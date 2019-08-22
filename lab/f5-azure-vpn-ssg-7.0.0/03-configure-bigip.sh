#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


EXT_NETWORK_UDF_PEERING="$(cat config.yml | grep EXT_NETWORK_UDF_PEERING | awk '{print $2}')"
MGT_NETWORK_UDF="$(cat config.yml | grep MGT_NETWORK_UDF | awk '{print $2}')"
SHARED_KEY="$(cat config.yml | grep SHARED_KEY | awk '{print $2}')"
VNET_CIDR_BLOCK="$(cat config.yml | grep VNET_CIDR_BLOCK | awk '{print $2}')"
PREFIX="$(head -40 config.yml | grep PREFIX | awk '{print $2}')"
PREFIXVPN="$PREFIX-vpn"

IPSEC_DESTINATION_NETWORK=$(grep IPSEC_DESTINATION_NETWORK ./config.yml | awk '{ print $2}')
IPSEC_DESTINATION_ADDRESS1=$(grep IPSEC_DESTINATION_ADDRESS1 ./config.yml | awk '{ print $2}')
IPSEC_DESTINATION_ADDRESS2=$(grep IPSEC_DESTINATION_ADDRESS2 ./config.yml | awk '{ print $2}')
IPSEC_DESTINATION_MASK=$(grep IPSEC_DESTINATION_MASK ./config.yml | awk '{ print $2}')

sshpass -p purple123 ssh-copy-id admin@$MGT_NETWORK_UDF > /dev/null 2>&1

publicIpAddress=$(az network public-ip show --name VNet1GWIP --resource-group $PREFIX | jq '.ipAddress')
publicIpAddress=${publicIpAddress:1:${#publicIpAddress}-2}
echo -e "\npublicIpAddress = ${BLUE} $publicIpAddress ${NC}"

echo -e "\n${GREEN}Setting sys db global parameters${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh modify sys db config.allow.rfc3927 { value "enable" } 
ssh admin@$MGT_NETWORK_UDF tmsh modify sys db ipsec.if.checkpolicy { value "disable" }
ssh admin@$MGT_NETWORK_UDF tmsh modify sys db connection.vlankeyed { value "disable" }

#echo -e "\n${GREEN}Setting BGP${NC}"
#ssh admin@$MGT_NETWORK_UDF tmsh modify net route-domain 0 routing-protocol add { BGP }

echo -e "\n${GREEN}Setting ipsec policy${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh create net ipsec ipsec-policy ipsec-policy-vpn-azure ike-phase2-auth-algorithm sha1 ike-phase2-encrypt-algorithm aes256 ike-phase2-lifetime 60 ike-phase2-perfect-forward-secrecy modp1024 mode interface

echo -e "\n${GREEN}Setting ipsec traffic selector${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh create net ipsec traffic-selector selector-vpn-azure destination-address 0.0.0.0/0 ipsec-policy ipsec-policy-vpn-azure source-address 0.0.0.0/0

echo -e "\n${GREEN}Setting ipsec IKE Peer${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh create net ipsec ike-peer peer-vpn-azure lifetime 480 my-id-type address my-id-value $EXT_NETWORK_UDF_PEERING peers-id-type address peers-id-value $publicIpAddress phase1-hash-algorithm sha1 prf sha1 phase1-auth-method pre-shared-key phase1-encrypt-algorithm aes256 remote-address $publicIpAddress verify-cert true version add { v2 } preshared-key $SHARED_KEY nat-traversal on traffic-selector add { selector-vpn-azure }

echo -e "\n${GREEN}Setting ipsec profile${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh create net tunnels ipsec profile-vpn-azure app-service none defaults-from ipsec traffic-selector selector-vpn-azure

echo -e "\n${GREEN}Setting ipsec tunnels${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh create net tunnels tunnel tunnel-vpn-azure local-address $EXT_NETWORK_UDF_PEERING mtu 1350 profile profile-vpn-azure remote-address $publicIpAddress

echo -e "\n${GREEN}Setting ipsec self IP${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh create net self $IPSEC_DESTINATION_ADDRESS1 address $IPSEC_DESTINATION_ADDRESS1/$IPSEC_DESTINATION_MASK allow-service all traffic-group traffic-group-local-only vlan tunnel-vpn-azure

echo -e "\n${GREEN}Setting ipsec pool${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh create ltm pool keepalive-vpn-azure members add { $IPSEC_DESTINATION_ADDRESS2:179 { address $IPSEC_DESTINATION_ADDRESS2 } } monitor tcp_half_open and gateway_icmp

echo -e "\n${GREEN}Setting ipsec virtual server${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh create ltm profile fastL4 vpn loose-close enabled loose-initialization enabled reset-on-timeout disabled
sleep 2
ssh admin@$MGT_NETWORK_UDF tmsh create ltm virtual vpn destination 0.0.0.0:any ip-forward profiles add { vpn }

echo -e "\n${GREEN}Add route${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh create net route azure_subnet interface tunnel-vpn-azure network $VNET_CIDR_BLOCK

echo -e "\n${GREEN}Save config${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh save sys config

echo -e "\n${GREEN}Restarting tmipsecd${NC}"
ssh admin@$MGT_NETWORK_UDF bigstart restart tmipsecd

# WA Tunnel
sleep 20
./wa_azure_vpn_down_bigip.sh

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\n(refresh every 1 min if not = Connected) -- Expected time: ${GREEN}~10 min${NC}"
while [[ $connectionStatus != "Connected" ]] 
do
    connectionStatus=$(az network vpn-connection show --name $PREFIXVPN --resource-group $PREFIX  | jq '.connectionStatus')
    connectionStatus=${connectionStatus:1:${#connectionStatus}-2}
    if [[ $connectionStatus == "Connected" ]]; then
      echo -e "connectionStatus =${GREEN} $connectionStatus ${NC}"
    else
      echo -e "connectionStatus =${RED} $connectionStatus ${NC}"
    fi
    sleep 60
done

exit 0