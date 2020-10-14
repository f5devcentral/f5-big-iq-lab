#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

home="/home/f5/traffic-scripts"
lampip="10.1.10.5"

already=$(ps -ef | grep "$0" | grep bash | grep -v grep | wc -l)
alreadypid=$(ps -ef | grep "$0" | grep bash | grep -v grep | awk '{ print $2 }')
if [  $already -gt 3 ]; then
    echo "The script is already running `expr $already - 2` time."
    exit 1
fi

sitefqdn[1]="site41.example.com" #https+ftp

# get length of the array
arraylength=${#sitefqdn[@]}

# Browser's list
browser[1]="Mozilla/5.0 (compatible; MSIE 7.01; Windows NT 5.0)"
browser[2]="Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/7.0; rv:11.0; Trident/7.0)"
browser[3]="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36"
browser[4]="Mozilla/5.0 (Windows NT 5.1; rv:7.0.1) Gecko/20100101 Firefox/7.0.1"
browser[5]="Mozilla/4.0 (compatible; MSIE 9.0; Windows NT 6.1)"
browser[6]="Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.0; Trident/5.0)"
browser[7]="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.89 Safari/537.36"
browser[8]="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36 OPR/43.0.2442.991"
browser[9]="Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 5 Build/JOP40D) AppleWebKit/535.19 (KHTML, like Gecko; googleweblight) Chrome/38.0.1025.166 Mobile Safari/535.19"
browser[10]="Mozilla/5.0 (Linux; Android 6.0.1; vivo 1603 Build/MMB29M) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.83 Mobile Safari/537.36"
browser[11]="Mozilla/5.0 (Linux; U; Android 4.0.4; pt-br; MZ608 Build/7.7.1-141-7-FLEM-UMTS-LA) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Safari/534.30"
browser[12]="Mozilla/5.0 (Linux; Android 7.0; SM-J730GM Build/NRD90M) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.111 Mobile Safari/537.36"
browser[13]="Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"
browser[14]="Mozilla/5.0 (iPad; CPU OS 10_2_1 like Mac OS X) AppleWebKit/602.4.6 (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/602.1"
browser[15]="Mozilla/5.0 (iPhone; CPU iPhone OS 9_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13E188a Safari/601.1"
browser[16]="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_4) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.1 Safari/603.1.30"
browser[17]="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/601.7.7 (KHTML, like Gecko) Version/9.1.2 Safari/601.7.7"
browser[18]="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36"
browser[19]="Mozilla/5.0 (BlackBerry; U; BlackBerry 9320; en) AppleWebKit/534.11+ (KHTML, like Gecko) Version/7.1.0.714 Mobile Safari/534.11+"
browser[20]="Mozilla/5.0 (Mobile; Windows Phone 8.1; Android 4.0; ARM; Trident/7.0; Touch; rv:11.0; IEMobile/11.0; NOKIA; Lumia 520) like iPhone OS 7_0_3 Mac OS X AppleWebKit/537 (KHTML, like Gecko) Mobile Safari/537"

arraylengthbrowser=${#browser[@]}

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
                # If 443 not anwser, trying port 80
                timeout 1 bash -c "cat < /dev/null > /dev/tcp/${ip:1:-1}/80"
                if [  $? == 0 ]; then
                        # Port 80 open
                        port=80
                else
                      port=0
                fi
        fi
        if [[  $port == 443 || $port == 80 ]]; then
        
                if [  $port == 443 ]; then
                        http="https://"
                else
                        http="http://"
                fi

                echo -e "\n# site $i ${sitefqdn[$i]} curl traffic gen ($http)"
                # add random number for loop
                r=`shuf -i 1-10 -n 1`;
                for k in `seq 1 $r`; do
                        echo "Loop $k"
                        #Randome IP
                        source_ip_address=$(dd if=/dev/urandom bs=4 count=1 2>/dev/null | od -An -tu1 | sed -e 's/^ *//' -e 's/  */./g')
                        echo $source_ip_address
                        #interface=$(/sbin/ifconfig | grep -B 1 $lampip | grep -v $lampip | awk -F':' '{ print $1 }')
                        #sudo ip addr add $source_ip_address/24 dev $interface
                        #sleep 1

                        # add random number for browsers
                        rb=`shuf -i 1-$arraylengthbrowser -n 1`;

                        echo -e "\n# site $i curl traffic gen ${sitefqdn[$i]}"
                        http_header="-H 'X-Forwarded-For: $source_ip_address' -H 'authority: ${sitefqdn[$i]}' -H 'pragma: no-cache' -H 'cache-control: no-cache' -H 'upgrade-insecure-requests: 1' -H 'dnt: 1' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'accept-encoding: gzip, deflate, br' -H 'accept-language: en-US,en;q=0.9,fr-FR;q=0.8,fr;q=0.7' --compressed"
    
                        echo "http_host_with_ip_address"
                        curl -k -s -o /dev/null $http_header  -A "${browser[$rb]}" -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total} source ip: $source_ip_address\n" $http${ip:1:-1} 

                        echo "http_max_uri_length"
                        curl -k -s -o /dev/null $http_header  -A "${browser[$rb]}" -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total} source ip: $source_ip_address\n" $http${sitefqdn[$i]}/1234567891234567890 

                        echo "http_server_webapp_ds_store_access"
                        curl -k -s -o /dev/null $http_header  -A "${browser[$rb]}" -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total} source ip: $source_ip_address\n" $http${sitefqdn[$i]}/.DS_Store 

                        echo "http_pua_adware_user_agent_vitruvian"
                        curl -k -s -o /dev/null -A Vitruvian -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total} source ip: $source_ip_address\n" $http${sitefqdn[$i]} 

                        echo "http_server_webapp_cgi_bin_access"
                        curl -k -m 10 -s -o /dev/null $http_header  -A "${browser[$rb]}" -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total} source ip: $source_ip_address\n" $http${sitefqdn[$i]}/cgi-bin/ 

                        echo "http_server_webapp_delete_attempt"
                        curl -k -m 10 -s -o /dev/null -X DELETE -w "status: %{http_code}\tbytes: %{size_download}\ttime: %{time_total} source ip: $source_ip_address\n" $http${sitefqdn[$i]}/search?q=test 

echo "ftp_anonymous_user"
ftp -n ${ip:1:-1} <<END_SCRIPT1
quote USER anonymous
quote PASS anonymous@example.com
quit
END_SCRIPT1

echo "ftp_admw0rm_ftp_login_attempt"
ftp -n ${ip:1:-1} <<END_SCRIPT3
quote USER w0rm
quote PASS secret
quit
END_SCRIPT3

                        sleep $r
                        #sudo ip addr del $source_ip_address/24 dev $interface
                done

                # This is outside the loop
                echo "ftp_bounce_attack"
                # http://etutorials.org/Networking/network+security+assessment/Chapter+8.+Assessing+FTP+and+Database+Services/8.4+FTP+Bounce+Attacks/
                nmap -P0 -b ftpuser:ftpuser@${ip:1:-1}:21 10.1.1.5
                
        else
                echo "SKIP ${sitefqdn[$i]} - $ip not answering on port 443 or 80"
        fi
   fi
done