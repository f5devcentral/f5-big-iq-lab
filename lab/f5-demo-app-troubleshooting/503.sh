#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ -z "$1" ];then
        url="site42.example.com"
else
        url=$1
fi

echo -e "\nHTTP app only.\nUsage: $0 site42.example.com"

echo -e "\nTarget:${GREEN} $url ${NC}\n"

echo -e "\nSending 500 HTTP requests:\n"

for i in {1..250};
do
        curl -s -o /dev/null -w "$i - f5_capacity_issue.php\tstatus: %{http_code}\tbytes: %{size_download}\ttime: %{time_total}\n" http://$url/f5_capacity_issue.php
done


echo -e "\n${BLUE}Simulator 503 completed.${NC}\n"