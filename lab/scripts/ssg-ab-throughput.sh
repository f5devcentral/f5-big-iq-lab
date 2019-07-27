#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

# -n requests     Number of requests to perform
# -c concurrency  Number of multiple requests to make

if [[ -z $1 ]]; then
        echo -e "Usage:"
		echo -e "# ./ssg-ab-throughput.sh site30.example.com (using http)"
		echo -e "# ./ssg-ab-throughput.sh site30.example.com https (using https)"
        exit 1;
fi

ip=$(ping -c 1 -w 1 $1 | grep PING | awk '{ print $3 }')

if [[ -z $2 ]]; then
	ab -n 1000000 -c 100 http://${ip:1:-1}/ > /dev/null 2>&1 &
	ssh admin@10.1.1.7 ab -n 1000000 -c 100 http://${ip:1:-1}/ > /dev/null 2>&1 &
	ssh admin@10.1.1.8 ab -n 1000000 -c 100 http://${ip:1:-1}/ > /dev/null 2>&1 &
	ssh admin@10.1.1.10 ab -n 1000000 -c 100 http://${ip:1:-1}/ > /dev/null 2>&1 &
	ssh admin@10.1.1.4 ab -n 1000000 -c 100 http://${ip:1:-1}/ > /dev/null 2>&1 &

else
	ab -n 1000000 -c 100 https://${ip:1:-1}/ &
	ssh admin@10.1.1.7 ab -n 1000000 -c 100 https://${ip:1:-1}/ > /dev/null 2>&1 &
	ssh admin@10.1.1.8 ab -n 1000000 -c 100 https://${ip:1:-1}/ > /dev/null 2>&1 &
	ssh admin@10.1.1.10 ab -n 1000000 -c 100 https://${ip:1:-1}/ > /dev/null 2>&1 &
	ssh admin@10.1.1.4 ab -n 1000000 -c 100 https://${ip:1:-1}/ > /dev/null 2>&1 &
fi


### KILL ALL AFTER 25 min

sleep 1500 && killall ab &
sleep 1500 && ssh admin@10.1.1.7 killall ab &
sleep 1500 && ssh admin@10.1.1.8 killall ab &
sleep 1500 && ssh admin@10.1.1.10 killall ab &
sleep 1500 && ssh admin@10.1.1.4 killall ab &

killall /bin/bash

exit 0;