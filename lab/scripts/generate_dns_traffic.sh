#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

home="/home/f5/scripts"

already=$(ps -ef | grep "$0" | grep bash | grep -v grep | wc -l)
if [  $already -gt 2 ]; then
    echo "The script is already running `expr $already - 2` time."
    killall $(basename "$0") > /dev/null 2>&1
    exit 1
fi

sitelistener[1]="10.1.10.203"
sitelistener[2]="10.1.10.204"

widip[1]="site36.example.com A"
widip[2]="f5.udf.example.com A"
widip[3]="office.example.com A"
widip[4]="airports.example.com A"
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
widip[15]="hr.example.com A"
widip[16]="airports.example.com AAAA"
widip[17]="airports.example.com MX"

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
            done
            echo -e "\n# site $i ${sitelistener[$i]} dnsperf"
            count=`shuf -i 100-300 -n 1`;
            conc=`shuf -i 50-100 -n 1`;
            sec=`shuf -i 20-60 -n 1`;
            queries=`shuf -i 20-60 -n 1`;
            dnsperf -s ${sitelistener[$i]} -d $home/dnstargets.txt -l $sec -c $conc -Q $queries -n $count
        else
            echo "SKIP ${sitelistener[$i]} - not answering on port 53"
        fi
   fi
done

rm -f $home/dnstargets.txt