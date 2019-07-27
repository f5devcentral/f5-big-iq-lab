#!/bin/bash
echo -e "\nSNMP TEST COMMAND: snmptrap -v 2c -c 'Tas' 10.1.1.5 '1234' 1.3.6.1.4.1.2.3 s s 'This is a Test'\n"
echo "disableAuthorization yes" > snmptrapd-test.conf
sudo snmptrapd -f -Lo -c snmptrapd-test.conf