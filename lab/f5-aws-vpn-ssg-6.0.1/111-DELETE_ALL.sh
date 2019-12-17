#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x
# Uncomment set command below for code debuging ansible
#DEBUG_arg="-vvvv"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function pause(){
   read -p "$*"
}

cd /home/f5/f5-aws-vpn-ssg

getPublicIP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
if [[ ! -z $getPublicIP ]]; then
    sed -i "s/$getPublicIP/0.0.0.0/g" ./config.yml
fi

c2=$(grep '<name>' ./config.yml | wc -l)
c3=$(grep '<name_of_the_aws_key>' ./config.yml | wc -l)
c4=$(grep '<key_id>' ./config.yml | wc -l)

if [[ $c2  == 1 || $c3  == 1 || $c4  == 1 ]]; then
       echo -e "${RED}\nNo AWS SSG created, nothing to tear down.\n${NC}"
       exit 1
fi

/usr/bin/wall "/!\ DELETION OF ALL AWS OBJECTS IN 1 MIN /!\  To stop it: # kill -9 $$" 2> /dev/null

sleep 60

echo -e "\n\n${RED}/!\ DELETION OF ALL AWS OBJECTS (Application/SSG/VPN/VPC) /!\ ${NC} \n"

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

clear

echo -e "\n\nEXPECTED TIME: ~25 min\n\n"

echo -e "${BLUE}TIME: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 10-delete-aws-app.yml -i inventory/hosts
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "\n\n${RED}/!\ HAVE YOU DELETED THE APP CREATED ON YOUR SSG FROM BIG-IQ? /!\ \n"
echo -e "IF YOU HAVE NOT, PLEASE DELETE ANY APPLICATION(S) CREATED ON YOUR AWS SSG BEFORE PROCEEDING ${NC}\n\n"

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 11-delete-aws-ssg-resources.yml -i inventory/hosts
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"
python 11-delete-aws-ssg-resources-check.py
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

echo -e "${RED}/!\ IS YOUR SSG COMPLETLY REMOVED FROM YOUR AWS ACCOUNT? /!\ \n"
echo -e "MAKE SURE THE AWS SSG HAS BEEN REMOVED COMPLETLY BEFORE PROCEEDING${NC}\n"

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"
ansible-playbook $DEBUG_arg 12-teardown-aws-vpn-vpc-ubuntu.yml
echo -e "\n${BLUE}TIME: $(date +"%H:%M")${NC}"

echo -e "Clear cache directory and *retry"
rm -rf cache *.retry nohup.out

echo -e "\n${RED}/!\ DOUBLE CHECK IN YOUR AWS ACCOUNT ALL THE RESOURCES CREATED FOR YOUR DEMO HAVE BEEN DELETED  /!\ ${NC}\n"

exit 0
