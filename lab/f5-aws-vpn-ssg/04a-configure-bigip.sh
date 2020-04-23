#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

VPC_CIDR_BLOCK="$(cat config.yml | grep VPC_CIDR_BLOCK | awk '{ print $2}')"
MGT_NETWORK_UDF="$(cat config.yml | grep MGT_NETWORK_UDF | awk '{ print $2}')"

sshpass -p purple123 ssh-copy-id -o StrictHostKeyChecking=no admin@$MGT_NETWORK_UDF > /dev/null 2>&1

echo -e "\n${GREEN}Setting sys db global parameters${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh modify sys db config.allow.rfc3927 { value "enable" } 
ssh admin@$MGT_NETWORK_UDF tmsh modify sys db ipsec.if.checkpolicy { value "disable" }
ssh admin@$MGT_NETWORK_UDF tmsh modify sys db connection.vlankeyed { value "disable" }

echo -e "\n${GREEN}Setting BGP${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh modify net route-domain 0 routing-protocol add { BGP }

ssh admin@$MGT_NETWORK_UDF tmsh create ltm profile fastL4 vpn loose-close enabled loose-initialization enabled reset-on-timeout disabled
sleep 2
ssh admin@$MGT_NETWORK_UDF tmsh create ltm virtual vpn destination 0.0.0.0:any ip-forward profiles add { vpn }

echo -e "\n${GREEN}Setting ipsec policy${NC}"
ssh admin@$MGT_NETWORK_UDF tmsh create net ipsec ipsec-policy ipsec-policy-vpn-aws ike-phase2-auth-algorithm sha1 ike-phase2-encrypt-algorithm aes256 ike-phase2-lifetime 60 ike-phase2-perfect-forward-secrecy modp1024 mode interface


exit 0