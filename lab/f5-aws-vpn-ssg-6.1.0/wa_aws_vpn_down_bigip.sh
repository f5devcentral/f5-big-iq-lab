#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

MGT_NETWORK_UDF="$(cat config.yml | grep MGT_NETWORK_UDF | awk '{print $2}')"

r=`shuf -i 1350-1360 -n 1`;

ssh admin@$MGT_NETWORK_UDF tmsh modify net tunnels tunnel aws_conn_tun_1 mtu $r
ssh admin@$MGT_NETWORK_UDF tmsh modify net tunnels tunnel aws_conn_tun_2 mtu $r

./check_vpn_aws.sh

exit 0