#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x
# Uncomment set command below for code debugging ansible
#DEBUG_arg="-vvvv"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function pause(){
   read -p "$*"
}

# Default value set to UDF
if [ -z "$2" ]; then
  env="udf"
else
  #env="sjc"
  #env="sjc2"
  env=$2
fi

# pass a variable in Ansible playbook
if [[  $env == "udf" ]]; then
    env_playbook="udf-bigiq-cm-01"
    user_playbook="auth_bigiq_david.json"
elif [[  $env == "sjc2" ]]; then
    env_playbook="sjc2-bigiq-cm-01"
    user_playbook=".auth_bigiq_admin.json"
fi

echo -e "\nEnvironement:${RED} $env ${NC}\n"

# Usage
if [[ -z $1 ]]; then
    echo -e "\nUsage: ${RED} $0 <pause/nopause> <udf/sjc/sjc2> ${NC} (1st parameter is mandatory)\n"
    exit 1;
fi

echo -e "\nUser being used:${BLUE}"
cat $user_playbook
echo -e "${NC}"

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

ansible-playbook -i inventory/$env-hosts as3_bigiq_task01_create_http_app.yml $DEBUG_arg --extra-vars "env=$env_playbook user=$user_playbook"
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
sleep 15

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
ansible-playbook -i inventory/$env-hosts as3_bigiq_task02_create_https_app.yml $DEBUG_arg --extra-vars "env=$env_playbook user=$user_playbook"
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
sleep 15

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
ansible-playbook -i inventory/$env-hosts as3_bigiq_task03a_create_waf_app.yml $DEBUG_arg --extra-vars "env=$env_playbook user=$user_playbook"
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
sleep 15

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
ansible-playbook -i inventory/$env-hosts as3_bigiq_task03b_create_waf_ext_policy_app.yml $DEBUG_arg --extra-vars "env=$env_playbook user=$user_playbook"
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
sleep 15

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
ansible-playbook -i inventory/$env-hosts as3_bigiq_task04_create_generic_app.yml $DEBUG_arg --extra-vars "env=$env_playbook user=$user_playbook"
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
sleep 15

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
ansible-playbook -i inventory/$env-hosts as3_bigiq_task05a_modify_post_http_app.yml $DEBUG_arg --extra-vars "env=$env_playbook user=$user_playbook"
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
sleep 15

[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
# Need to use an admin user to create the template (using david)
ansible-playbook -i inventory/$env-hosts as3_bigiq_task06_create_template.yml $DEBUG_arg --extra-vars "env=$env_playbook user=$user_playbook"
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
sleep 15

echo -e "\n${RED}Warning${NC}: Follow Task 8 from the lab guide:\n Assign ${BLUE}HTTPcustomTemplateTask6${NC} template to Applicator Creator AS3 custom role and remove the ${BLUE}default${NC} template from the allowed list).\n"
echo -e "\nUser being used:${BLUE}"
user_playbook="auth_bigiq_olivia.json"
cat $user_playbook
echo -e "${NC}"
pause "Press [Enter] key to continue... CTRL+C to Cancel"
ansible-playbook -i inventory/$env-hosts as3_bigiq_task08_create_http_app.yml $DEBUG_arg --extra-vars "env=$env_playbook user=$user_playbook"
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
sleep 15

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
[[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
ansible-playbook -i inventory/$env-hosts as3_bigiq_task10_create_http_app_fqdn_nodes.yml $DEBUG_arg --extra-vars "env=$env_playbook user=$user_playbook"
echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
