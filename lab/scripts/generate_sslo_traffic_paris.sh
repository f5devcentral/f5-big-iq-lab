#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

already=$(ps -ef | grep "$0" | grep bash | grep -v grep | wc -l)
if [  $already -gt 2 ]; then
    echo "The script is already running `expr $already - 2` time."
    killall $(basename "$0")
    exit 1
fi

bigip1="10.1.20.13"  #Paris
bigip2="10.1.20.7"   #Seattle

# if AWS, do not run the SSLO script just yet
type=$(cat /sys/hypervisor/uuid | grep ec2 | wc -l)
if [[  $type == 1 ]]; then
    # aws
    exit 2;
fi

# Only run the script if PARIS-vBIGIP01.termmarc.com.v14.1 is alive.

if ping -c 1 $bigip1 &> /dev/null
then
    echo "Change gateway to SSLo Paris as Default Gateway"
    sudo ip route change default via $bigip1 dev eth2
    sleep 2s
    echo "Generate traffic through SSLo Paris"
    count=1
    while [ $count -le 30 ]
    do
    curl -k https://www.chase.com
    curl -k https://www.f5.com
    curl -k https://www.youtube.com
    curl -k https://www.facebook.com
    curl -k https://www.nginx.com
    curl -k https://hackazon.paris.f5se.com
    curl -k https://www.perdu.com
    curl -k https://www.health.com
    curl -k https://www.harley-davidson.com/fr/fr/index.html
    curl -k https://www.mizuhobank.co.jp/index.html
    curl -k https://www.bde.es/bde/es/
    curl -k https://societegenerale.bj
    ((count++))
    done

    echo "Change gateway to SSLo Seattle as Default Gateway"
    sudo ip route change default via $bigip2 dev eth2
    sleep 2s
    echo "Generate traffic through SSLo Paris"
    count=1
    while [ $count -le 30 ]
    do
    curl -k https://mabanque.bnpparibas
    curl -k https://www.f5.com
    curl -k https://www.suresnes.fr
    curl -k https://www.youtube.com
    curl -k https://harobikes.com/pages/bmx
    curl -k https://www.suunto.com
    curl -k https://www.ford.fr
    curl -k https://www.harley-davidson.com/fr/fr/index.html
    curl -k https://www.mizuhobank.co.jp/index.html
    curl -k https://www.bde.es/bde/es/
    curl -k https://societegenerale.bj
    ((count++))
    done

    echo "Change gateway to default gateway"
    interface=$(ifconfig | grep -B 1 10.1.1.5 | grep -v 10.1.1.5 | awk -F':' '{ print $1 }')
    # check if AWS or Ravello
    type=$(cat /sys/hypervisor/uuid | grep ec2 | wc -l)
    if [[  $type == 1 ]]; then
        echo "AWS"
        sudo ip route change default via 10.1.1.1 dev $interface
    else
        echo "Ravello"
        sudo ip route change default via 10.1.1.2 dev $interface
    fi

else
    echo "$bigip1 not up. Please start PARIS-vBIGIP01.termmarc.com.v14.1, SSLo Service TAP and SSLo Service Inline L2 in UDF."
fi