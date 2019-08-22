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

for i in {1..10};
do
        curl -s -o /dev/null -w '404demo.php\tstatus: %{http_code}\tbytes: %{size_download}\ttime: %{time_total}\n' http://$url/404demo.php
        sleep 10;
done

echo -e "\n${BLUE}Simulator 404 completed.${NC}\n"