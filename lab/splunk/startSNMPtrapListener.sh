#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x

user="f5student"
home="/home/$user"

# Install SNMP linux package
sudo apt install snmp -y

echo -e "\nLaunching snmptrapd, redirecting SNMP traps into $home/splunk/snmp/snmp-traps.log: \n"
sudo killall snmptrapd > /dev/null 2>&1

mkdir $home/splunk/snmp > /dev/null 2>&1
sudo snmptrapd -Lf $home/splunk/snmp/snmp-traps.log --disableAuthorization=yes
sudo snmptrap -v 2c -c 'Tas' 10.1.1.5 '1234' 1.3.6.1.4.1.2.3 s s 'This is a Test'
sudo snmptrapd -m +ALL # MIBs located under /usr/share/snmp/mibs/
cat $home/splunk/snmp/snmp-traps.log

# Monitor snmp-traps.log in splunk
docker exec splunk_splunk_1 sudo -u root /opt/splunk/bin/splunk add monitor /var/log/snmp/snmp-traps.log -auth admin:purple123
