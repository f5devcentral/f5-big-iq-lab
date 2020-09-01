#!/bin/bash

user="f5student"
home="/home/$user"

echo -e "\nLaunching snmptrapd, redirecting SNMP traps into $home/snmptrap/snmp-traps.log: \n"
sudo killall snmptrapd > /dev/null 2>&1
# Link snmp traps log file to splunk directory so he can be monitor in Splunk
ln -snf $home/snmptrap/snmp-traps.log $home/splunk/snmp/snmp-traps.log

sudo snmptrapd -Lf $home/splunk/snmp/snmp-traps.log --disableAuthorization=yes
sudo snmptrap -v 2c -c 'Tas' 10.1.1.5 '1234' 1.3.6.1.4.1.2.3 s s 'This is a Test'
sudo snmptrapd -m +ALL # MIBs located under /usr/share/snmp/mibs/
cat $home/snmptrap/snmp-traps.log

# Monitor snmp-traps.log in splunk
docker exec splunk_splunk_1 sudo -u root /opt/splunk/bin/splunk add monitor /var/log/snmp/snmp-traps.log -auth admin:purple123


