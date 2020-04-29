#!/bin/bash

## This script creates dynamic basline traffic
echo "Traffic Baselining"

VS_ADDR="10.1.10.138"

home="/home/f5/scripts/behavioral-DoS"

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
				for i in $(eval echo "{0..`date +%M`}")
                                do
                                        #Randome IP
                                        rip=`shuf -i 1-254 -n 1`;
                                        source_ip_address="10.1.10.$rip"
                                        curl -0 -s -o /dev/null --header "X-Forwarded-For: $source_ip_address" -A "`shuf -n 1 $home/source/useragents_with_bots.txt`" -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total} ip: $source_ip_address\n" http://$VS_ADDR`shuf -n 1 $home/source/urls.txt`
                                        curl -0 -s -o /dev/null --header "X-Forwarded-For: $source_ip_address" -A "`shuf -n 1 $home/source/useragents_with_bots.txt`"  http://$VS_ADDR`shuf -n 1 $home/source/urls.txt`
                                        curl -0 -s -o /dev/null --header "X-Forwarded-For: $source_ip_address" -A "`shuf -n 1 $home/source/useragents_with_bots.txt`"  http://$VS_ADDR`shuf -n 1 $home/source/urls.txt`
                                done
                                #sleep 0.1
                        done    
                ;;
                "alternate")
                        while true; do
                                clear
                                echo "Hourly alternate traffic: $VS_ADDR"
                                echo
                                if (( `date +%k` % 2 )); then
                                        for i in {1..100};
                                        do
                                                #Randome IP
                                                rip=`shuf -i 1-254 -n 1`;
                                                source_ip_address="10.1.10.$rip"
                                                curl -0 -s -o /dev/null -H "X-Forwarded-For: $source_ip_address" -A "`shuf -n 1 $home/source/useragents_with_bots.txt`" -w "High:\tstatus: %{http_code}\tbytes: %{size_download}\ttime: %{time_total} ip: $source_ip_address\n" http://$VS_ADDR`shuf -n 1 $home/source/urls.txt`
                                                curl -0 -s -o /dev/null -H "X-Forwarded-For: $source_ip_address" -A "`shuf -n 1 $home/source/useragents_with_bots.txt`"  http://$VS_ADDR`shuf -n 1 $home/source/urls.txt`
                                                curl -0 -s -o /dev/null -H "X-Forwarded-For: $source_ip_address" -A "`shuf -n 1 $home/source/useragents_with_bots.txt`"  http://$VS_ADDR`shuf -n 1 $home/source/urls.txt`
                                        done
                                else
                                        for i in {1..50};
                                        do
                                                #Randome IP
                                                rip=`shuf -i 1-254 -n 1`;
                                                source_ip_address="10.1.10.$rip"
                                                curl -s -o /dev/null -H "X-Forwarded-For: $source_ip_address" -A "`shuf -n 1 $home/source/useragents_with_bots.txt`" -w "High:\tstatus: %{http_code}\tbytes: %{size_download}\ttime: %{time_total} ip: $source_ip_address\n" http://$VS_ADDR`shuf -n 1 $home/source/urls.txt`
                                                curl -s -o /dev/null -H "X-Forwarded-For: $source_ip_address" -A "`shuf -n 1 $home/source/useragents_with_bots.txt`"  http://$VS_ADDR`shuf -n 1 $home/source/urls.txt`
                                                curl -s -o /dev/null -H "X-Forwarded-For: $source_ip_address" -A "`shuf -n 1 $home/source/useragents_with_bots.txt`"  http://$VS_ADDR`shuf -n 1 $home/source/urls.txt`
                                        done
                                fi
                                #sleep 0.1
                                clear
                        done
                ;;
                "Quit")
                        break
                ;;
        *) echo invalid option;;
    esac
done
