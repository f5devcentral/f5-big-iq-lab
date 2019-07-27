#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

home="/home/f5/scripts"
dcdip="10.1.10.6"

already=$(ps -ef | grep "$0" | grep bash | grep -v grep | wc -l)
if [  $already -gt 2 ]; then
    echo "The script is already running `expr $already - 2` time."
    killall $(basename "$0")
    exit 1
fi

echo "# generate_access_reports_data.sh"
cd $home/access
count=`shuf -i 1-2 -n 1`;
./generate_access_reports_data.sh accessmock 1.1.1.1 BOS-vBIGIP01.termmarc.com,BOS-vBIGIP02.termmarc.com $dcdip $count;
count=`shuf -i 1-2 -n 1`;
./generate_access_reports_data.sh access 10.1.10.222 BOS-vBIGIP01.termmarc.com,BOS-vBIGIP02.termmarc.com $dcdip $count;
count=`shuf -i 1-2 -n 1`;
./generate_access_reports_data.sh accesssessions 10.1.10.222 BOS-vBIGIP01.termmarc.com,BOS-vBIGIP02.termmarc.com $dcdip $count;

echo "# generate_access_reports_mock_data.sh"
cd $home/access
count=`shuf -i 1-2 -n 1`;
./generate_access_reports_mock_data.sh $dcdip BOS-vBIGIP01.termmarc.com $count
count=`shuf -i 1-2 -n 1`;
./generate_access_reports_mock_data.sh $dcdip BOS-vBIGIP02.termmarc.com $count

#echo "# rate-ht-sender.py"
#cd $home/access
#./rate-ht-sender.py --log-iq $dcdip

#echo "# generate_data.sh"
#cd $home/access
#count=`shuf -i 1-4 -n 1`;
#./generate_data.sh 10.1.10.222 access $count
#count=`shuf -i 1-4 -n 1`;
#./generate_data.sh 10.1.10.222 all $count

