#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x

echo -e "\nTIME: $(date +"%H:%M")"

cd /home/f5/f5-vmware-ssg

ansible-playbook -i notahost, get_status_vm.yaml

# parse JSON
if [ -f vmfact.json ]; then
    jq '.virtual_machines' vmfact.json
    rm -f vmfact.json
fi