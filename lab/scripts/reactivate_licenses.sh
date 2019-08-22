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
generate_post_data() {
cat <<EOF
{
    "state": "RELICENSE",
    "method": "AUTOMATIC"
}
EOF
}

# Specific to UDF license pools
byolpool[1]="7686f428-3849-4450-a1a2-ea288c6bcbe0" #byol-pool
byolpool[2]="2b161bb3-4579-44f0-8792-398f7f54512e" #byol-pool-access 
byolpool[3]="0a2f68b5-1646-4a60-a276-8626e3e9fb8e" #byol-pool-perAppVE

# get length of the array
arraylength=${#byolpool[@]}

for (( i=1; i<${arraylength}+1; i++ ));
do
    echo "byol-pool $1"
    curl -k -i \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
    -X PATCH --data "$(generate_post_data)" "https://$bigiq_user:$bigiq_password@$bigiq/mgmt/cm/device/licensing/pool/purchased-pool/licenses/${byolpool[$i]}"
done

############# ############# ############# 
#############    Utility    ############# 
############# ############# ############# 
generate_post_data() {
cat <<EOF
{
    status: "ACTIVATING_AUTOMATIC"
}
EOF
}

# Specific to UDF license pools
byolutility[1]="A2762-65666-03770-68885-8401075" #byol-pool-utility 

# get length of the array
arraylength2=${#byolutility[@]}

for (( i=1; i<${arraylength2}+1; i++ ));
do
    echo "byol-utility $1"
    curl -k -i \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
    -X PATCH --data "$(generate_post_data)" "https://$bigiq_user:$bigiq_password@$bigiq/mgmt/cm/device/licensing/pool/utility/licenses/${byolutility[$i]}"
done