#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x
# Uncomment set command below for code debugging ansible
#DEBUG_arg="-vvvv"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default value set to UDF
if [ -z "$3" ]; then
  env="udf"
else
  #env="sjc"
  #env="sjc2"
  env=$3
fi

echo -e "\nEnvironement:${RED} $env ${NC}\n"

# Usage
if [[ -z $1 || -z $2 ]]; then
    echo -e "\nUsage: ${RED} $0 <playbook.yml> <admin/david/paula/paul/olivia> <udf/sjc/sjc2> ${NC} (1st and 2nd parameters mandatory)\n"
    ls -l *.yml
    exit 1;
fi


if [ ! -f $1 ]; then
    echo -e "\n${RED}ERROR: $1 playbook${NC} does not exist.\n"
    ls -l *.yml
    exit 2;
fi

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# pass a variable in Ansible playbook
if [[  $env == "udf" ]]; then
    env_playbook="udf-bigiq-cm-01"
    if [[  $2 == "admin" ]]; then
        user_playbook="auth_bigiq_admin.json"
    else
        user_playbook="auth_bigiq_$2.json"
    fi
elif [[  $env == "sjc2" ]]; then
    env_playbook="sjc2-bigiq-cm-01"
    if [[  $2 == "admin" ]]; then
        user_playbook=".auth_bigiq_admin.json"
    else
        user_playbook="auth_bigiq_$2.json"
    fi
elif [[  $env == "sjc" ]]; then
    env_playbook="sjc-bigiq-cm-01"
    if [[  $2 == "admin" ]]; then
        user_playbook=".auth_bigiq_admin.json"
    else
        user_playbook="auth_bigiq_$2.json"
    fi
fi

if [ ! -f $user_playbook ]; then
    echo -e "\n${RED}ERROR: $user_playbook user json file${NC} does not exist.\n"
    ls -lrt auth_bigiq*
    exit 3;
fi

echo -e "\nUser being used:${BLUE}"
cat $user_playbook
echo -e "${NC}"

ansible-playbook -i inventory/$env-hosts $1 $DEBUG_arg --extra-vars "taskid=$1 env=$env_playbook user=$user_playbook"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"