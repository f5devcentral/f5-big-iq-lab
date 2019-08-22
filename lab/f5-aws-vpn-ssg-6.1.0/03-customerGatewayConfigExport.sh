#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x

PREFIX="$(head -25 config.yml | grep PREFIX | awk '{ print $2}')"
PREFIXVPN="$PREFIX-vpn"

aws ec2 describe-vpn-connections --query 'VpnConnections[*].{ID:CustomerGatewayConfiguration}' --filters Name=tag:Name,Values=$PREFIXVPN --output text > ./cache/$PREFIX/3-customer_gateway_configuration.xml

if [ -f ./cache/$PREFIX/3-customer_gateway_configuration.xml ]; then
   sed -i '1d' ./cache/$PREFIX/3-customer_gateway_configuration.xml
   # Remove the first line if contains None
   if [ $(grep None ./cache/$PREFIX/3-customer_gateway_configuration.xml) ]; then
     sed -i '/None/d' ./cache/$PREFIX/3-customer_gateway_configuration.xml
   fi
   # In case 1st line is missing
   if [[ ! $(grep 'vpn_connection id' ./cache/$PREFIX/3-customer_gateway_configuration.xml) ]]; then
     rm -f ./cache/$PREFIX/3-customer_gateway_configuration.xml
     aws ec2 describe-vpn-connections --query 'VpnConnections[*].{ID:CustomerGatewayConfiguration}' --filters Name=tag:Name,Values=$PREFIXVPN --output text > ./cache/$PREFIX/3-customer_gateway_configuration.xml
   fi
   echo "Customer Gateway Configuration file export OK"
else
   echo "Customer Gateway Configuration file export NOK. Check if you VPN connection was created successfully"
   # Stop parent script
   kill -9 `ps --pid $$ -oppid=`; exit
fi

exit 0
