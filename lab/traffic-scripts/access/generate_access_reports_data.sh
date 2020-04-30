#!/usr/bin/env bash
#
# File: generate_access_reports_data.sh
#
# Author: Karthikeyan Ramasamy (k.ramasamy@f5.com)
#
# Description:
# This script will generate data for SWG and access reports.
# please run this script where you have JAVA running in the path. For example sjcdev07 or seadev01 (shared dev servers)
# Alternatively have java installed on your mac workstations and you can run the script from there
#

CONFIGURATION_TYPE=$1 #Configuration can be all,swg or access
VIRTUAL_IP=$2 #Add your virtual ip which you used to configure your BIGIP
BIGIP_HOSTNAME=$3 
LOGIQ_SELFIP=$4 

#No need to modify this the below params unless you want to have custom swg data.
SWG_DATA_TRAFFIC_FILE=resources/swg_traffic_data.txt   #file from which the swg requests are made
SWG_PORT=3128
	
runs=$5;
runCount=0;
c=1;

echo "runs: $runs"

timechar=${runs: -1}


if [ "$timechar" == "d" ]
   then
   runCount=$((${runs::-1}*24*60));	
elif [ "$timechar" == "h" ]
   then
   runCount=$((${runs::-1}*60));
else 
  runCount=$runs;
fi

echo "count: $runCount"


 while [ $c -le $runCount ]	
   do
     
       if [ "$CONFIGURATION_TYPE" == "all" ] || [ "$CONFIGURATION_TYPE" == "access" ] || [ "$CONFIGURATION_TYPE" == "accesssessions" ]
	then
		echo "Generating Access Sessions in BIG-IP"
	        count=$[1 + $RANDOM % 3 ]
	        echo "Number of Sessions: $count"
		java -jar resources/access_reports_data_generator.jar --host $VIRTUAL_IP --sessions $count
	fi

	if [ "$CONFIGURATION_TYPE" == "all" ] || [ "$CONFIGURATION_TYPE" == "accessmock" ] || [ "$CONFIGURATION_TYPE" == "access" ] 
	then
		count=$[2 + $RANDOM % 3 ]
		echo "Generating Access mock sessions: $count"
		java -cp resources/access_reports_data_generator.jar eventlogs.DemoAccessEventLogsGenerator $LOGIQ_SELFIP $BIGIP_HOSTNAME $count
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
			sleep 2
		done < $USERS_FILE

	fi        
      
        echo "Iteration c: $c"
        
        if [ $c -lt $runCount ]
            then
	      echo "Wait for few seconds before next iteration"
              sleep 55
        fi

      ((c++))

  done

  echo "Completed generating Data generation for Reports"
