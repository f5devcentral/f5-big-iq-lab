#!/bin/bash

echo -e "* kill all jobs in sleep"
sudo killall sleep > /dev/null 2>&1
sudo killall perl > /dev/null 2>&1

for filename in ./*sh; do
    filename=${filename:2:${#filename}}
    echo -e "* $filename"
    for process in $(ps -ef | grep $filename | grep -v grep | grep -v $0 | grep -v reactivate_licenses.sh | awk '{print $2}'); do
      echo -e "\tkill -9 $process"
      sudo kill -9 $process
    done
done

# Kill some extra stuff (launched by generate_dns_ddos_traffic_real.sh)
sudo killall nping hping3

# Reset default GW in case SSLO script gets kill in the middle of it
sudo ip route change default via 10.1.1.2 dev eth0