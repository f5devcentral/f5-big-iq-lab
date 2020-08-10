#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x
# Uncomment set command below for code debugging ansible
#DEBUG_arg="-vvvv"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Usage
if [[ -z $1 || -z $2 ]]; then
    echo -e "\nUsage:${RED} $0 <as3declaration.json> <admin/david/paula/paul/olivia>\n"
    ls -l as3/ | grep -v total | awk '{print $NF}'
    echo
    exit 1;
fi

if [ ! -f as3/$1 ]; then
    echo -e "\nERROR:${RED} $1 ${NC}does not exist!\n"
    ls -l as3/ | grep -v total | awk '{print $NF}'
    echo
    exit 2;
fi

if [[  $2 == "admin" ]]; then
    user_playbook="auth_bigiq_admin.json"
else
    user_playbook="auth_bigiq_$2.json"
fi

if [ ! -f $user_playbook ]; then
    echo -e "\n${RED}ERROR: $user_playbook user json file${NC} does not exist.\n"
    ls -lrt auth_bigiq* | grep -v total | awk '{print $NF}'
    echo
    exit 3;
fi

### Docker build and check
docker build -t f5-big-iq-onboarding .
docker run f5-big-iq-onboarding ansible-playbook --version
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}Docker running.${NC}"
else
    echo -e "\n${RED}Docker not running or not installed. Exit.\nMaybe try to cleanup/restart processes:${NC}"
    echo -e "\ndocker kill $(docker ps -q)"
    echo -e "\ndocker stop $(docker ps -q)"
    echo -e "\ndocker rm $(docker ps -a -q)"
    echo -e "\ndocker rmi $(docker images -q) -f"
    echo -e "\nsystemctl enable docker"
    echo -e "\n/etc/init.d/docker restart"
    exit 9;
fi

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

echo -e "\nUser being used:${BLUE}"
cat $user_playbook
echo -e "${NC}"

echo -e "\n${GREEN}Create AS3 Applications:${NC}\n"
cat as3/$1 | jq .
echo
echo
./ansible_helper ansible-playbook /ansible/bigiq_as3_deploy.yml -i /ansible/hosts --extra-vars "as3app=as3/$1 user=$user_playbook" $DEBUG_arg

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
