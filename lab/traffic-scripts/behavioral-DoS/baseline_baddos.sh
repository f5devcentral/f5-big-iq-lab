#!/bin/bash

## This script creates dynamic basline traffic
echo "Traffic Baselining"

VS_ADDR="10.1.10.138"

home="/home/f5/traffic-scripts/behavioral-DoS"

interface=$(/sbin/ifconfig | grep -B 1 10.1.10.5 | grep -v 10.1.10.5 | awk -F':' '{ print $1 }')

stop_flag=0

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
    echo "** Trapped CTRL-C"
    sudo ip link set $interface down
    sudo ip link set $interface up
    sleep 5
    ip addr show $interface
    stop_flag=1
    exit 1;
}
 
BASELINE='Please enter your type of baslining: '
options=("increasing" "alternate" "Quit")
select opt in "${options[@]}"
do
        case $opt in
                "increasing")
                        while true; do
                                clear
                                echo "Hourly increasing traffic: $VS_ADDR"   
                                echo
                                #Randome IP
                                rip=`shuf -i 6-150 -n 1`;
                                source_ip_address="10.1.10.$rip"
                                sudo ip addr add $source_ip_address/24 dev $interface
				for i in $(eval echo "{0..`date +%M`}")
                                do
                                        j=5
                                        for k in `seq 1 $j`; do
                                                curl -0 -s -o /dev/null --interface $source_ip_address --header "X-Forwarded-For: $source_ip_address" -A "`shuf -n 1 $home/source/useragents_with_bots.txt`" -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total} ip: $source_ip_address (i=$j)\n" http://$VS_ADDR`shuf -n 1 $home/source/urls.txt`
                                        done
                                done
                                sudo ip addr del $source_ip_address/24 dev $interface
                                sleep 0.2
                        done    
                ;;
                "alternate")
                        while true; do
                                clear
                                echo "Hourly alternate traffic: $VS_ADDR"
                                echo
                                if (( `date +%k` % 2 )); then
                                        #Randome IP
                                        rip=`shuf -i 151-253 -n 1`;
                                        source_ip_address="10.1.10.$rip"
                                        sudo ip addr add $source_ip_address/24 dev $interface
                                        for i in {1..100};
                                        do
                                                j=5
                                                for k in `seq 1 $j`; do
                                                        curl -0 -s -o /dev/null --interface $source_ip_address --header "X-Forwarded-For: $source_ip_address" -A "`shuf -n 1 $home/source/useragents_with_bots.txt`" -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total} ip: $source_ip_address (i=$j)\n" http://$VS_ADDR`shuf -n 1 $home/source/urls.txt`
                                                done
                                        done
                                        sudo ip addr del $source_ip_address/24 dev $interface
                                else
                                        #Randome IP
                                        rip=`shuf -i 151-253 -n 1`;
                                        source_ip_address="10.1.10.$rip"
                                        sudo ip addr add $source_ip_address/24 dev $interface
                                        for i in {1..100};
                                        do
                                                j=5
                                                for k in `seq 1 $j`; do
                                                        curl -0 -s -o /dev/null --interface $source_ip_address --header "X-Forwarded-For: $source_ip_address" -A "`shuf -n 1 $home/source/useragents_with_bots.txt`" -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total} ip: $source_ip_address (i=$j)\n" http://$VS_ADDR`shuf -n 1 $home/source/urls.txt`
                                                done
                                        done
                                        sudo ip addr del $source_ip_address/24 dev $interface
                                fi
                                sleep 0.2
                        done
                ;;
                "Quit")
                        break
                ;;
        *) echo invalid option;;
    esac
done
