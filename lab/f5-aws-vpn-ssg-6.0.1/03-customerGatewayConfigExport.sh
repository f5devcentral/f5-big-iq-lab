#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x

PREFIX="$(head -20 config.yml | grep PREFIX | awk '{ print $2}')"
PREFIXVPN="$PREFIX-vpn"

aws ec2 describe-vpn-connections --query 'VpnConnections[*].{ID:CustomerGatewayConfiguration}' --filters Name=tag:Name,Values=$PREFIXVPN --output text > ./cache/$PREFIX/3-customer_gateway_configuration.xml

if [ -f ./cache/$PREFIX/3-customer_gateway_configuration.xml ]; then
   sed -i '1d' ./cache/$PREFIX/3-customer_gateway_configuration.xml
   if [ $(grep None ./cache/$PREFIX/3-customer_gateway_configuration.xml) ]; then
     sed -i '/None/d' ./cache/$PREFIX/3-customer_gateway_configuration.xml
   fi
   if [ ! $(grep 'vpn_connection id' ./cache/$PREFIX/3-customer_gateway_configuration.xml) ]; then
     sed -i '1 s/^/<vpn_connection id="vpn-03dcde03d0c5877dd">\n/' ./cache/$PREFIX/3-customer_gateway_configuration.xml
   fi
   echo "Customer Gateway Configuration file export OK"
else
   echo "Customer Gateway Configuration file export NOK. Check if you VPN connection was created successfully"
   # Stop parent script
   kill -9 `ps --pid $$ -oppid=`; exit
fi

exit 0
