#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

# BIG-IQ must be configured for basic auth, in the console run `set-basic-auth on`
bigiq="10.1.1.4"
bigiq_user="admin"
bigiq_password="purple123" 

############# ############# ############# 
############# License Pool  ############# 
############# ############# ############# 

purchasedPoolselfLink=( $(curl -k https://$bigiq_user:$bigiq_password@$bigiq/mgmt/cm/device/licensing/pool/purchased-pool/licenses | jq -r .items | jq .[].selfLink | awk -F '/' '{print $11}' | sed 's/.$//') )
printf '%s\n' "${purchasedPoolselfLink[@]}"

purchasedPoolname=( $(curl -k https://$bigiq_user:$bigiq_password@$bigiq/mgmt/cm/device/licensing/pool/purchased-pool/licenses | jq -r .items | jq .[].name | sed 's:^.\(.*\).$:\1:') )
printf '%s\n' "${purchasedPoolname[@]}"

purchasedPoolbaseRegKey=( $(curl -k https://$bigiq_user:$bigiq_password@$bigiq/mgmt/cm/device/licensing/pool/purchased-pool/licenses | jq -r .items | jq .[].baseRegKey | sed 's:^.\(.*\).$:\1:') )
printf '%s\n' "${purchasedPoolbaseRegKey[@]}"

# get length of the array
arraylength=${#purchasedPoolname[@]}
echo $arraylength

for (( i=0; i<${arraylength}; i++ ));
do

    echo "byol-pool $1"

    # Delete Existing Licenses using self link
    curl -k -i \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
    -X DELETE "https://$bigiq_user:$bigiq_password@$bigiq/mgmt/cm/device/licensing/pool/purchased-pool/licenses/${purchasedPoolselfLink[$i]}"

    # Add it back using previous name and baseRegKey
    curl -k -i \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
    -X POST --data "{\"baseRegKey\": \"${purchasedPoolbaseRegKey[$i]}\",\"name\": \"${purchasedPoolname[$i]}\",\"method\": \"AUTOMATIC\"}" "https://$bigiq_user:$bigiq_password@$bigiq/mgmt/cm/device/licensing/pool/purchased-pool/licenses"

done


############# ############# ############# 
#############    Utility    ############# 
############# ############# ############# 

utilityPoolRegKey=( $(curl -k https://$bigiq_user:$bigiq_password@$bigiq/mgmt/cm/device/licensing/pool/utility/licenses | jq -r .items | jq .[].regKey | sed 's:^.\(.*\).$:\1:') )
printf '%s\n' "${utilityPoolRegKey[@]}"

# get length of the array
arraylength=${#utilityPoolRegKey[@]}

for (( i=0; i<${arraylength}; i++ ));
do

    echo "byol-pool-utility $1"

    curl -k -i \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
    -X PATCH --data "{status: \"ACTIVATING_AUTOMATIC\"}" "https://$bigiq_user:$bigiq_password@$bigiq/mgmt/cm/device/licensing/pool/utility/licenses/${utilityPoolRegKey[$i]}"
done