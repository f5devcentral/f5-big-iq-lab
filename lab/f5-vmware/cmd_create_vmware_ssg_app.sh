#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x
# Uncomment set command below for code debugging ansible
#DEBUG_arg="-vvvv"

# ESXi IP address
ip="10.1.1.90"

echo -e "\nTIME: $(date +"%H:%M")"

cd /home/f5/f5-vmware

if [ -f /home/f5/ssg_created ]; then
    echo -e "SSG already created.\n"
    ./cmd_power_on_vm.sh
else
    # check if ESXi is up
    timeout 1 bash -c "cat < /dev/null > /dev/tcp/$ip/443"
    if [  $? == 0 ]; then
        # Below playbook works only with vmwareUDFdefault cloud environement pre-created in the BIG-IQ Blueprint
        ansible-playbook $DEBUG_arg -i inventory/hosts create_vmware-auto-scaling.yml

        echo -e "\n${GREEN}Sleep 25 min (to allow time for the SSG to come up)${NC}"
        sleep 1500
        # check if ESXi is up
        timeout 1 bash -c "cat < /dev/null > /dev/tcp/$ip/443"
        if [  $? == 0 ]; then
            # create defauilt app on the SSG
            python create_http_bigiq_app_ssg.py
        fi
        # get VM status
        ./cmd_get_status_vm.sh

        touch ssg_created
    else
        echo -e "ESXi shutdown"
    fi
fi