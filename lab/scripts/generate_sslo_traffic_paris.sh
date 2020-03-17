#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

bigip1="10.1.20.13"  #Paris BIG-IP
bigip2="10.1.20.7"   #Seattle BIG-IP
lamp1="10.1.1.5"    #Lamp server management IP
lamp2="10.1.20.5"   #Lamp server internal IP
interface2=$(ifconfig | grep -B 1 $lamp2 | grep -v $lamp2 | awk -F':' '{ print $1 }')

already=$(ps -ef | grep "$0" | grep bash | grep -v grep | wc -l)
if [  $already -gt 2 ]; then
    echo "The script is already running `expr $already - 2` time."
    killall $(basename "$0") > /dev/null 2>&1
    exit 1
fi

# check if AWS or Ravello
type=$(cat /sys/hypervisor/uuid | grep ec2 | wc -l)

# Only run the script if PARIS-vBIGIP01.termmarc.com.v14.1 is alive.
if ping -c 1 $bigip1 &> /dev/null
then
    echo "Add routes to SSLo Paris for all URL below"

    sitefqdn[1]="chase.com"
    sitefqdn[2]="f5.com"
    sitefqdn[3]="www.youtube.com"
    sitefqdn[4]="facebook.com"
    sitefqdn[5]="nginx.com"
    sitefqdn[6]="perdu.com"
    sitefqdn[7]="health.com"
    sitefqdn[8]="harley-davidson.com"
    sitefqdn[9]="www.boj.or.jp"
    sitefqdn[10]="bde.es"
    sitefqdn[11]="societegenerale.bj"

    # get length of the array
    arraylength=${#sitefqdn[@]}

    for (( i=1; i<${arraylength}+1; i++ ));
    do
        if [ ! -z "${sitefqdn[$i]}" ]; then
            ip=$(ping -c 1 -w 1 ${sitefqdn[$i]} | grep PING | awk '{ print $3 }')
            echo "Generate traffic through SSLo Paris for ${sitefqdn[$i]} - $ip"
            sudo ip route add ${ip:1:-1} via $bigip1 dev $interface2
            sleep 2s
            count=1
            while [ $count -le 30 ]
            do
                curl -o /dev/null -k https://${sitefqdn[$i]}
                ((count++))
            done
            sudo ip route del ${ip:1:-1} via $bigip1 dev $interface2
        fi
    done

    sitefqdn[1]="mabanque.bnpparibas"
    sitefqdn[2]="f5.com"
    sitefqdn[3]="suresnes.fr"
    sitefqdn[4]="youtube.com"
    sitefqdn[5]="harobikes.com/pages/bmx"
    sitefqdn[6]="suunto.com"
    sitefqdn[7]="ford.fr"
    sitefqdn[8]="harley-davidson.com"
    sitefqdn[9]="www.boj.or.jp"
    sitefqdn[10]="bde.es"
    sitefqdn[11]="societegenerale.bj"

    # get length of the array
    arraylength=${#sitefqdn[@]}

    for (( i=1; i<${arraylength}+1; i++ ));
    do
        if [ ! -z "${sitefqdn[$i]}" ]; then
            ip=$(ping -c 1 -w 1 ${sitefqdn[$i]} | grep PING | awk '{ print $3 }')
            sudo ip route add ${ip:1:-1} via $bigip2 dev $interface2
            echo "Generate traffic through SSLo Seattle for ${sitefqdn[$i]} - $ip"
            sleep 2s
            count=1
            while [ $count -le 30 ]
            do
                curl -o /dev/null -k https://${sitefqdn[$i]}
                ((count++))
            done
            sudo ip route del ${ip:1:-1} via $bigip2 dev $interface2
        fi
    done

else
    echo "$bigip1 not up. Please start PARIS-vBIGIP01.termmarc.com.v14.1, SSLo Service TAP and SSLo Service Inline in UDF."
fi