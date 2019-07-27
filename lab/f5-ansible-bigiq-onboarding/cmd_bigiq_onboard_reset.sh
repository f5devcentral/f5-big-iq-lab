#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x
# Uncomment set command below for code debugging ansible
#DEBUG_arg="-vvvv"

# Default value set to UDF
if [ -z "$2" ]; then
  env="udf"
else
  #env="sjc"
  #env="sjc2"
  env=$2
fi

############################################################################################
# CONFIGURATION
ip_cm1="$(cat inventory/group_vars/$env-bigiq-cm-01.yml| grep bigiq_onboard_server | awk '{print $2}')"
ip_dcd1="$(cat inventory/group_vars/$env-bigiq-dcd-01.yml| grep bigiq_onboard_server | awk '{print $2}')"

declare -a ips=("$ip_cm1" "$ip_dcd1")
############################################################################################

function pause(){
   read -p "$*"
}

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Usage
if [[ -z $1 ]]; then
    echo -e "\nUsage: ${RED} $0 <pause/nopause> [<udf/sjc/sjc2> <rmAS3rpmBigipOnly>] ${NC}([] = optional)\n"
    exit 1;
fi

# SECONDS used for total execution time (see end of the script)
SECONDS=0

echo -e "\nEnvironement:${RED} $env ${NC}"

echo -e "Exchange ssh keys with BIG-IQ & DCD:"
if [[  $env == "udf" ]]; then
  for ip in "${ips[@]}"; do
    echo "$ip"
    sshpass -p purple123 ssh-copy-id -o StrictHostKeyChecking=no -i /home/f5/.ssh/id_rsa.pub root@$ip
  done
fi

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

## If 3rd parameter is empty, run clea-rest-storage on the BIG-IQ/DCD + Reboot (UDF)
if [[ -z $3 ]]; then
  echo -e "\n${RED}=>>> clear-rest-storage -d${NC} on both BIG-IQ CM and DCD"

  for ip in "${ips[@]}"; do
    echo -e "\n---- ${RED} $ip ${NC} ----"
    [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
    echo "clear-rest-storage"
    ssh -o StrictHostKeyChecking=no root@$ip clear-rest-storage -d
  done

  ### CUSTOMIZATION - UDF ONLY (otherwise, the licensing doesn't work)
  if [[ $env == "udf" ]]; then
    [[ $1 != "nopause" ]] && pause "Press [Enter] key to continue... CTRL+C to Cancel"
    echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
    echo -e "\n${RED}Waiting 5 min ... ${NC}"
    sleep 300
    for ip in "${ips[@]}"; do
      echo -e "\n---- ${RED} $ip ${NC} ----"
      echo "reboot"
      ssh -o StrictHostKeyChecking=no root@$ip reboot
    done
  fi
else
  echo -e "\n${RED}Skipping clear-rest-storage"
fi

### CUSTOMIZATION - F5 INTERNAL LAB ONLY =>>>>> rmAS3rpmBigipOnly below un-install AS3 LX packages from BIG-IPs
if [[  $env != "udf" ]]; then
    echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"
    # Cleanup AS3 on the BIG-IP
    while IFS="," read -r a b c;
    do
        echo -e "Exchange ssh keys with BIG-IP:"
        echo "Type $a root password (if asked)"
        sshpass -p $c ssh-copy-id -o StrictHostKeyChecking=no -i /home/f5/.ssh/id_rsa.pub $b@$a > /dev/null 2>&1

        echo "Cleanup AS3 on $a"

        CREDS="admin:$c"
        CURL_FLAGS="--silent -k -u $CREDS"

        poll_task () {
          STATUS="STARTED"
          while [ $STATUS != "FINISHED" ]; do
              sleep 1
              RESULT=$(curl ${CURL_FLAGS} "https://$a/mgmt/shared/iapp/package-management-tasks/$1")
              STATUS=$(echo $RESULT | jq -r .status)
              if [ $STATUS = "FAILED" ]; then
                  echo "Failed to" $(echo $RESULT | jq -r .operation) "package:" \
                      $(echo $RESULT | jq -r .errorMessage)
                  exit 1
              fi
          done
        }

        TASK=$(curl $CURL_FLAGS -H "Content-Type: application/json" \
            -X POST https://$a/mgmt/shared/iapp/package-management-tasks -d "{operation: 'QUERY'}")
        poll_task $(echo $TASK | jq -r .id)
        AS3RPMS=$(echo $RESULT | jq -r '.queryResponse[].packageName | select(. | startswith("f5-"))')

        #Uninstall existing f5-appsvcs packages on target
        for PKG in $AS3RPMS; do
            echo "Uninstalling $PKG on $a"
            DATA="{\"operation\":\"UNINSTALL\",\"packageName\":\"$PKG\"}"
            TASK=$(curl ${CURL_FLAGS} "https://$a/mgmt/shared/iapp/package-management-tasks" \
                --data $DATA -H "Origin: https://$a" -H "Content-Type: application/json;charset=UTF-8")
            poll_task $(echo $TASK | jq -r .id)
        done

        #ssh -o StrictHostKeyChecking=no $b@$a bigstart stop restjavad restnoded < /dev/null
        #ssh -o StrictHostKeyChecking=no $b@$a rm -rf /var/config/rest/storage < /dev/null
        #ssh -o StrictHostKeyChecking=no $b@$a rm -rf /var/config/rest/index < /dev/null
        #ssh -o StrictHostKeyChecking=no $b@$a bigstart start restjavad restnoded < /dev/null
        #ssh -o StrictHostKeyChecking=no $b@$a rm -f /var/config/rest/downloads/*.rpm < /dev/null
        #ssh -o StrictHostKeyChecking=no $b@$a rm -f /var/config/rest/iapps/RPMS/*.rpm < /dev/null
    done < inventory/$env-bigip.csv
fi

echo -e "\n${BLUE}TIME:: $(date +"%H:%M")${NC}"

# total script execution time
echo -e "$(date +'%Y-%d-%m %H:%M'): elapsed time:${RED} $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec${NC}"