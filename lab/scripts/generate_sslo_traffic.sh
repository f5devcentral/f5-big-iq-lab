#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

bigip1="10.1.20.13"  #Paris BIG-IP
bigip2="10.1.20.7"   #Seattle BIG-IP
lamp1="10.1.1.5"    #Lamp server management IP
lamp2="10.1.20.5"   #Lamp server internal IP
ifconfigcmd=$(which ifconfig)
interface2=$($ifconfigcmd | grep -B 1 $lamp2 | grep -v $lamp2 | awk -F':' '{ print $1 }')

already=$(ps -ef | grep "$0" | grep bash | grep -v grep | wc -l)
alreadypid=$(ps -ef | grep "$0" | grep bash | grep -v grep | awk '{ print $2 }')
if [  $already -gt 2 ]; then
    echo "The script is already running `expr $already - 2` time."
    kill -9 $alreadypid > /dev/null 2>&1
    exit 1
fi

ipcmd=$(which ip)

# check if AWS or Ravello
type=$(cat /sys/hypervisor/uuid | grep ec2 | wc -l)

# Only run the script if PARIS-vBIGIP01.termmarc.com.v14.1 is alive.
if ping -c 1 $bigip1 &> /dev/null
then
    echo "Add routes to SSLo Paris for all URL below"

    sitefqdn[1]="www.chase.com"
    sitefqdn[2]="www.f5.com"
    sitefqdn[3]="www.youtube.com"
    sitefqdn[4]="www.facebook.com"
    sitefqdn[5]="www.nginx.com"
    sitefqdn[6]="www.perdu.com"
    sitefqdn[7]="www.health.com"
    sitefqdn[8]="www.renault.fr"
    sitefqdn[9]="www.boj.or.jp"
    sitefqdn[10]="www.bancopan.com.br"
    sitefqdn[11]="www.bde.es"
    sitefqdn[12]="societegenerale.bj"
    sitefqdn[13]="www.bangkokpost.com"

    # get length of the array
    arraylength=${#sitefqdn[@]}

    for (( i=1; i<${arraylength}+1; i++ ));
    do
        if [ ! -z "${sitefqdn[$i]}" ]; then
            ip=$(ping -c 1 -w 1 ${sitefqdn[$i]} | grep PING | awk '{ print $3 }')
            r=`shuf -i 1-15 -n 1`;
            echo "Generate traffic through SSLo Paris for ${sitefqdn[$i]} - $ip (loop $r)"
            sudo $ipcmd route add ${ip:1:-1} via $bigip1 dev $interface2
            $ipcmd route show | grep ${ip:1:-1}
            count=1
            while [ $count -le $r ]
            do
                curl -s -o /dev/null -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total}\n" -k https://${sitefqdn[$i]}
                ((count++))
            done
            sudo $ipcmd route del ${ip:1:-1} via $bigip1 dev $interface2
        fi
    done

    sitefqdn[1]="mabanque.bnpparibas"
    sitefqdn[2]="www.f5.com"
    sitefqdn[3]="www.suresnes.fr"
    sitefqdn[4]="www.youtube.com"
    sitefqdn[5]="harobikes.com"
    sitefqdn[6]="www.suunto.com"
    sitefqdn[7]="www.ford.fr"
    sitefqdn[8]="www.renault.fr"
    sitefqdn[9]="www.boj.or.jp"
    sitefqdn[10]="www.bancopan.com.br"
    sitefqdn[11]="www.bde.es"
    sitefqdn[12]="societegenerale.bj"
    sitefqdn[13]="www.bangkokpost.com"

    # get length of the array
    arraylength=${#sitefqdn[@]}

    for (( i=1; i<${arraylength}+1; i++ ));
    do
        if [ ! -z "${sitefqdn[$i]}" ]; then
            ip=$(ping -c 1 -w 1 ${sitefqdn[$i]} | grep PING | awk '{ print $3 }')
            r=`shuf -i 1-15 -n 1`;
            sudo $ipcmd route add ${ip:1:-1} via $bigip2 dev $interface2
            echo "Generate traffic through SSLo Seattle for ${sitefqdn[$i]} - $ip (loop $r)"
            $ipcmd route show | grep ${ip:1:-1}
            count=1
            while [ $count -le $r ]
            do
                curl -s -o /dev/null -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total}\n" -k https://${sitefqdn[$i]}
                ((count++))
            done
            sudo $ipcmd route del ${ip:1:-1} via $bigip2 dev $interface2
        fi
    done

else
    echo "$bigip1 not up. Please start PARIS-vBIGIP01.termmarc.com.v14.1, SSLo Service TAP and SSLo Service Inline in UDF."
fi