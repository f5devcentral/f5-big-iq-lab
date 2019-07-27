#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x

release="v7.0.0"
#release="v6.1.0"
#release="v6.0.1.1"
#release="v6.0.1.2"
build="current"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Usage
if [[ -z $1 ]]; then
    echo -e "\nUsage: ${RED} $0 [<build number>] ${NC}([] = optional)\n"
    exit 1;
fi

echo -e "\n${GREEN}BIG-IQ FQDN in UDF (e.g. e3eaa7ef-190e-4da6-bd5b-64d70f8faeeb.access.udf.f5.com):${NC}"
read fqdn

echo -e "\n${GREEN}Port (e.g. 47000):${NC}"
read port

echo -e "\n${GREEN}SSH priv key saved in UDF: (e.g. ~/.ssh/id_rsa):${NC}"
read sshkey

echo -e "\n${GREEN}F5 domain:${NC}"
read f5domain

echo -e "\n${GREEN}Download iso${NC}"

## Cleanup
rm -f *iso *iso.md5 *iso.md5.verify
# remove cookie if older than 1 day
if [[ $(find "./.cookie" -mmin +120 -print 2> /dev/null) ]]; then
  echo -e "\nDeleted .cookie older than 2 hours"
  rm -f ./.cookie
fi
if [ ! -f ./.cookie ]; then
  # Corporate user/password to download the latest iso
  echo -e "\n${GREEN}Corporate F5 username:${NC}"
  read f5user
  echo -e "${GREEN}Corporate F5 password:${NC}"
  read -s f5pass
fi

## download iso file
curl "https://weblogin.$f5domain/sso/login.php?redir=https://nibs.$f5domain/build" -H "Connection: keep-alive" -H "Pragma: no-cache" -H "Cache-Control: no-cache" -H "Origin: https://weblogin.$f5domain" -H "Upgrade-Insecure-Requests: 1" -H "DNT: 1" -H "Content-Type: application/x-www-form-urlencoded" -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" -H "Referer: https://weblogin.$f5domain/sso/login.php?msg=Invalid%20Credentials&redir=https://nibs.$f5domain/build" -H "Accept-Encoding: gzip, deflate, br" -H "Accept-Language: en-US,en;q=0.9,fr-FR;q=0.8,fr;q=0.7" --data "user=$f5user&pass=$f5pass&submit_form=Submit" --compressed -c ./.cookie
curl -b ./.cookie -o - https://nibs.$f5domain/build/bigiq/$release/daily/$build/ | grep BIG-IQ | grep 'iso"'  | awk '{print $6}' | grep -oP '(?<=").*(?=")' > iso.txt
iso=$(cat iso.txt)
curl -b ./.cookie -o - https://nibs.$f5domain/build/bigiq/$release/daily/$build/$iso > $iso
curl -b ./.cookie -o - https://nibs.$f5domain/build/bigiq/$release/daily/$build/$iso.md5 > $iso.md5
md5sum $iso > $iso.md5.verify
DIFF=$(diff $iso.md5.verify $iso.md5) 
if [[  "$DIFF" != "" ]]; then
    echo -e "The md5 is different."
    cat $iso.md5
    cat $iso.md5.verify
    exit 2;
else
    echo -e "\nIso is good!\n"
    ls -lrt $iso*
fi

echo -e "\n${GREEN}Transfer iso to BIG-IQ CM in UDF:${NC}"
scp -o "StrictHostKeyChecking no" -P $port -i $sshkey $iso $fqdn:/shared/images/
