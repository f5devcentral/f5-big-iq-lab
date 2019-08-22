#!/usr/bin/env bash
#
# File: generate_access_reports_mock_data.sh
#
# Author: Karthikeyan Ramasamy (k.ramasamy@f5.com)
#
# Description:
# This script will generate mock sessions and log messages for access reports.Please note this script generate the data directly 
# in BIG-IQ and you will not see a corresponding session in BIG-IQ. You can use this script to generate data for Session By Geo Location ,
# Bad Ip Reputation, Brower US Charts
# please run this script where you have JAVA running in the path. Example bigip, seadev , sjcdev
# argument 1 is the LOG-IQ managenet ip 
# argument 2 is the BIG-IP hostname for which session needs to be created
# argument 3 is how many access sessions are required to be created defaults to 500
#
# example ./generate_access_reports_mock_data.sh 10.192.123.87 karabip1new.lab.fp.f5.com 5000 - This will create 5000 access session with hostname  karabip1new.lab.fp.f5.com on the BIG-IQ 10.192.123.87
#

BIG_IQ="$1"
BIG_IP_HOSTNAME="$2"  #hostname of the BIG-IP 
SESSIONS_COUNT="$3"

if [ -z "$SESSIONS_COUNT" ]
	then 
	SESSIONS_COUNT=25
fi

echo "Generating Access Mock Data"
java -jar resources/accessreports_mockdata.jar $BIG_IQ $BIG_IP_HOSTNAME $SESSIONS_COUNT
echo "Completed generating data generation for reports"

