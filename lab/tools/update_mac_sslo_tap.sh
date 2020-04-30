#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

##### INSTALLATION
## Configured in /etc/rc.local
## curl -o /home/ubuntu/update_mac_tap.sh https://raw.githubusercontent.com/f5devcentral/f5-big-iq-lab/develop/lab/tools/update_mac_sslo_tap.sh
## chmod +x /home/ubuntu/update_mac_tap.sh
## /home/ubuntu/update_mac_tap.sh > /home/ubuntu/update_mac_tap.log

#################### INFORMATION #################### 
# Prerequisists to allow change mac address on BIG-IP (due to UDF changing MAC address evertime a new BP is started)
# Disable strictness on TAP service on BIG-IQ

bigip1="10.1.1.13"  #Paris BIG-IP
bigip2="10.1.1.7"   #Seattle BIG-IP

mac=$(ifconfig ens4 | grep ether | awk '{ print $2 }')

echo -e "\nThis is the MAC address which will be set in the BIG-IPs TAP service:\n$mac"

json="{
    \"macAddress\": \"$mac\",
    \"kind\": \"tm:net:arp:arpstate\",
    \"name\": \"ssloS_trend_tap4\",
    \"partition\": \"Common\",
    \"subPath\": \"ssloS_trend_tap.app\",
    \"fullPath\": \"/Common/ssloS_trend_tap.app/ssloS_trend_tap4\",
    \"generation\": 0,
    \"selfLink\": \"https://localhost/mgmt/tm/net/arp/~Common~ssloS_trend_tap.app~ssloS_trend_tap4?ver=14.1.0.3\",
    \"appService\": \"/Common/ssloS_trend_tap.app/ssloS_trend_tap\",
    \"appServiceReference\": {
        \"link\": \"https://localhost/mgmt/tm/sys/application/service/~Common~ssloS_trend_tap.app~ssloS_trend_tap?ver=14.1.0.3\"
    },
    \"ipAddress\": \"198.19.0.10\"
}"

# Seattle BIG-IP
while ! ping -c 1 $bigip2 &> /dev/null
do
    echo -e "\nWait 5min: $bigip2 unreachable\n"
    sleep 300
done
echo -e "\nUpdate BIG-IP $bigip2\n"
res=$(curl -s -k -u "admin:purple123" -H "Content-Type: application/json" -X PUT -d "$json" https://$bigip2/mgmt/tm/net/arp/~Common~ssloS_trend_tap.app~ssloS_trend_tap4)
echo $res

# Wait 1 min
sleep 60

while [[ ${res} == *"code"* ]] || [[ ${res} == *"xml"* ]] &> /dev/null
do
    echo -e "\nWait 1min: $bigip2 not ready to receive API call.\n"
    sleep 60
    res=$(curl -s -k -u "admin:purple123" -H "Content-Type: application/json" -X PUT -d "$json" https://$bigip2/mgmt/tm/net/arp/~Common~ssloS_trend_tap.app~ssloS_trend_tap4)
    echo $res
done

# Paris BIG-IP
while ! ping -c 1 $bigip1 &> /dev/null
do
    echo -e "\nWait 5min: $bigip1 unreachable\n"
    sleep 300
done
echo -e "\nUpdate BIG-IP $bigip1\n"
res=$(curl -s -k -u "admin:purple123" -H "Content-Type: application/json" -X PUT -d "$json" https://$bigip1/mgmt/tm/net/arp/~Common~ssloS_trend_tap.app~ssloS_trend_tap4)
echo $res

# Wait 1 min
sleep 60

while [[ ${res} == *"code"* ]] || [[ ${res} == *"xml"* ]] &> /dev/null
do
    echo -e "\nWait 1min: $bigip1 not ready to receive API call.\n"
    sleep 60
    res=$(curl -s -k -u "admin:purple123" -H "Content-Type: application/json" -X PUT -d "$json" https://$bigip1/mgmt/tm/net/arp/~Common~ssloS_trend_tap.app~ssloS_trend_tap4)
    echo $res
done