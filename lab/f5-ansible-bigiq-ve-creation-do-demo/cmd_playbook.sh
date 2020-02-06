#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x
# Uncomment set command below for code debugging ansible
#DEBUG_arg="-vvvv"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

env="udf"

echo -e "\nEnvironement:${RED} $env ${NC}\n"

# Usage
if [[ -z $1 || -z $2 ]]; then
    echo -e "\nUsage: ${RED} $0 <playbook.yml> <admin/david> ${NC}\n"
    ls -l *.yml
    exit 1;
fi


if [ ! -f $1 ]; then
    echo -e "\n${RED}ERROR: $1 playbook${NC} does not exist.\n"
    ls -l *.yml
    exit 2;
fi

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
env_playbook="udf-bigiq-cm-01"

if [[  $2 == "admin" ]]; then
    user_playbook="auth_bigiq_admin.json"
else
    user_playbook="auth_bigiq_$2.json"
fi

if [ ! -f $user_playbook ]; then
    echo -e "\n${RED}ERROR: $user_playbook user json file${NC} does not exist.\n"
    ls -lrt auth_bigiq* | grep -v total | awk '{print $NF}'
    exit 3;
fi

echo -e "\nUser being used:${BLUE}"
cat $user_playbook
echo -e "${NC}"

## ADD LOGIC TO SHOW LIST OF CLOUD ENV AVAILABLE
# VMware: 

ansible-playbook -i inventory/$env-hosts $1 $DEBUG_arg --extra-vars "taskid=$1 env=$env_playbook user=$user_playbook vename=$vename cloudEnvironmentReference=$cloudEnvironmentReference"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"