#!/bin/bash

## This script creates dynamic basline traffic
echo "Traffic Baselining"

VS_ADDR="10.1.10.138"
SRC_ADDR1="10.1.10.100"

# Add source IP address
sudo ip addr add $SRC_ADDR1/24 dev ens4:1

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
                                                curl -0 --interface $SRC_ADDR1 -s -o /dev/null -A "`shuf -n 1 ./source/useragents_with_bots.txt`" -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total}\n" http://$VS_ADDR`shuf -n 1 ./source/urls.txt`
                                                curl -0 --interface $SRC_ADDR1 -s -o /dev/null -A "`shuf -n 1 ./source/useragents_with_bots.txt`"  http://$VS_ADDR`shuf -n 1 ./source/urls.txt`
                                                curl -0 --interface $SRC_ADDR1 -s -o /dev/null -A "`shuf -n 1 ./source/useragents_with_bots.txt`"  http://$VS_ADDR`shuf -n 1 ./source/urls.txt`
                                                #curl -0 -s -o /dev/null -A "`sort -R ./source/useragents_with_bots.txt | head -1`" -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total}\n" http://$VS_ADDR`sort -R ./source/urls.txt | head -1`
                                        done
                                #sleep 0.1
                        done    
                ;;
                "alternate")
                        while true; do
                                clear
                                echo "Hourly alternate traffic: $VS_ADDR"
                                echo
                                #if (( {`date +%k` % 2} )); then
                                if (( `date +%k` % 2 )); then
                                        for i in {1..100};
                                                do
                                                        curl -0 --interface $SRC_ADDR1 -s -o /dev/null -A "`shuf -n 1 ./source/useragents_with_bots.txt`" -w "High:\tstatus: %{http_code}\tbytes: %{size_download}\ttime: %{time_total}\n" http://$VS_ADDR`shuf -n 1 ./source/urls.txt`
                                                        curl -0 --interface $SRC_ADDR1 -s -o /dev/null -A "`shuf -n 1 ./source/useragents_with_bots.txt`"  http://$VS_ADDR`shuf -n 1 ./source/urls.txt`
                                                        curl -0 --interface $SRC_ADDR1 -s -o /dev/null -A "`shuf -n 1 ./source/useragents_with_bots.txt`"  http://$VS_ADDR`shuf -n 1 ./source/urls.txt`
#                                                	curl -0 -s -o /dev/null -A "`sort -R ./source/useragents_with_bots.txt | head -1`" -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total}\n" http://$VS_ADDR`sort -R ./source/urls.txt | head -1`
                                                done
                                else
                                        for i in {1..50};
                                                do
                                                        curl --interface $SRC_ADDR1 -s -o /dev/null -A "`shuf -n 1 ./source/useragents_with_bots.txt`" -w "High:\tstatus: %{http_code}\tbytes: %{size_download}\ttime: %{time_total}\n" http://$VS_ADDR`shuf -n 1 ./source/urls.txt`
                                                        curl --interface $SRC_ADDR1 -s -o /dev/null -A "`shuf -n 1 ./source/useragents_with_bots.txt`"  http://$VS_ADDR`shuf -n 1 ./source/urls.txt`
                                                        curl --interface $SRC_ADDR1 -s -o /dev/null -A "`shuf -n 1 ./source/useragents_with_bots.txt`"  http://$VS_ADDR`shuf -n 1 ./source/urls.txt`
                                                #curl -0 -s -o /dev/null -A "`sort -R ./source/useragents_with_bots.txt | head -1`" -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total}\n" http://$VS_ADDR`sort -R ./source/urls.txt | head -1`
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
