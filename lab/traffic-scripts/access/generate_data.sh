#!/usr/bin/env bash
#
# File: generate_data.sh
#
# Author: vishal chawathe (v.chawathe@f5.com)
#
# Description:
# This script will generate data for SWG and access reports.
# please run this script where you have JAVA running in the path. Example bigip
# argument 1 is the virtual server ip 
# argument 2 is what data admin wishes to generate: possible combinations "all","access","swg"
# argument 3 is how many access sessions are required to be created defaults to 100
#
# example ./generate_data.sh 10.192.123.130 all 100 - This will create 100 access session and also swg traffic  on virtual ip 10.192.123.130
#

BIG_IP="$1"
CONFIGURATION_TYPE="$2"  #Configuration can be all,swg or access
ACCESS_SESSIONS_COUNT="$3"
if [ -z "$CONFIGURATION_TYPE" ]
	then 
	CONFIGURATION_TYPE="all"
fi

if  [ "$CONFIGURATION_TYPE" == "all" ] || [ "$CONFIGURATION_TYPE" == "access" ]  || ["$CONFIGURATION_TYPE" == "swg" ]
then
	echo "setting default value for configuration type as all"
	CONFIGURATION_TYPE="all"
fi

if [ -z "$ACCESS_SESSIONS_COUNT" ]
	then 
	ACCESS_SESSIONS_COUNT=3
fi

#export PATH="$PATH:/usr/lib/jvm/jre/bin/"

if [ "$CONFIGURATION_TYPE" == "all" ] || [ "$CONFIGURATION_TYPE" == "access" ]
then
	echo "Generating Access Data"
	java -jar resources/SessionGen.jar --host $BIG_IP --sessions $ACCESS_SESSIONS_COUNT
fi

if [ "$CONFIGURATION_TYPE" == "all" ] || [ "$CONFIGURATION_TYPE" == "swg" ]
then
	echo "Generating SWG Data"
		USERS_FILE="./resources/users.txt"
		SITE_LIST="./resources/swg_traffic_data.txt"

		while read line 
		do
			echo "Generation traffic for user: $line"
			./generate_each_user_data.sh "$BIG_IP" "$line" "my_test_password" $SITE_LIST
			sleep 10
		done < $USERS_FILE

fi
echo "Completed generating data generation for reports"
