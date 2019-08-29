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
env="udf"

echo -e "\nEnvironement:${RED} $env ${NC}\n"

# Usage
if [[ -z $1 ]]; then
    echo -e "\nUsage: ${RED} $0 <task ID>${NC}\n"
    exit 1;
fi

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# pass a variable in Ansible playbook
env_playbook="udf-bigiq-cm-01"
user_playbook="auth_bigiq_admin.json"

ansible-playbook -i inventory/$env-hosts as3_bigiq_check_task_status.yml $DEBUG_arg --extra-vars "taskid=$1 env=$env_playbook user=$user_playbook"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"