#!/usr/bin/env bash
#
# File: setup_bigip.sh
#
# Author: vishal chawathe (v.chawathe@f5.com)
#
# Description:
# This script will generate data for SWG and access reports.
# please run this script where you have JAVA running in the path. For example sjcdev07 or seadev01 (shared dev servers)
# Alternatively have java installed on your mac workstations and you can run the script from there
#

set -x


VIRTUAL_IP="$1"  #Add your virtual ip which you used to configure your BIGIP

#No need to modify this the below params unless you want to have custom swg data.
SWG_DATA_TRAFFIC_FILE="$4"
#resources/swg_traffic_data.txt   #file from which the swg requests are made
SWG_PORT=3128
USERNAME="$2"
PASSWORD="$3"
PROXY="$USERNAME:$PASSWORD@$VIRTUAL_IP:$SWG_PORT"
PROXY_ARG="-x $PROXY"

while read line
do
        REPEAT_NUM=$(($RANDOM%3))
        if [ "$REPEAT_NUM" -gt "0" ]; then
                urlName=$line
                echo "Traffic generated for url: $urlName"
                curl --insecure -L $PROXY_ARG $urlName
                echo "Sleeping 2 seconds"
                sleep 2
            else
                echo "Skipping: $urlName"
        fi
done < $SWG_DATA_TRAFFIC_FILE

