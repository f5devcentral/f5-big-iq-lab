#!/bin/bash

## Inbound interface
inbound_interface=ens6
inbound_ip=10.1.30.14
inbound_mask=24
inbound_gw=10.1.30.7

## Outbound interface
outbound_interface=ens7
outbound_ip=10.1.40.14
outbound_mask=24
outbound_gw=10.1.40.7


### ---------------------------------------------- ###
### ---------------------------------------------- ###

## static table names
inbound_table=av_in
outbound_table=av_out

## function to get network from mask and IP
get_network () {
   IFS=. read -r io1 io2 io3 io4 <<< "$2"
   set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
   [ $1 -gt 1 ] && shift $1 || shift
   NET_ADDR="$((${io1} & ${1-0})).$((${io2} & ${2-0})).$((${io3} & ${3-0})).$((${io4} & ${4-0}))"
   echo "$NET_ADDR"
}

## stop if iproute2 isn not installed
if ! [ -d "/etc/iproute2/" ]; then
    echo "iproute2 policy routing is not available on this system - exiting"
    exit
fi

echo "create iproute2 tables"
## create the ipproute2 tables
if ! grep -q ${inbound_table} /etc/iproute2/rt_tables; then
    echo "200 ${inbound_table}" >> /etc/iproute2/rt_tables
fi
if ! grep -q ${outbound_table} /etc/iproute2/rt_tables; then
    echo "201 ${outbound_table}" >> /etc/iproute2/rt_tables
fi

## get the inbound and outbound networks from function
inbound_net=$(get_network ${inbound_mask} ${inbound_ip})
outbound_net=$(get_network ${outbound_mask} ${outbound_ip})

## create policy routes
ip rule add iif ${inbound_interface} table ${inbound_table}
ip rule add iif ${outbound_interface} table ${outbound_table}
echo "add addr"
ip addr add ${inbound_ip}/${inbound_mask} brd + dev ${inbound_interface}
ip addr add ${outbound_ip}/${outbound_mask} brd + dev ${outbound_interface}
echo "add route"
ip route add ${inbound_net}/${inbound_mask} dev ${inbound_interface} proto kernel scope link src ${inbound_ip} table ${inbound_table}
ip route add ${inbound_net}/${inbound_mask} dev ${inbound_interface} proto kernel  scope link src ${inbound_ip} table ${outbound_table}
ip route add ${outbound_net}/${outbound_mask} dev ${outbound_interface} proto kernel scope link src ${outbound_ip} table ${inbound_table}
ip route add ${outbound_net}/${outbound_mask} dev ${outbound_interface} proto kernel scope link src ${outbound_ip} table ${outbound_table}
echo "${outbound_gw} table ${inbound_table}"
ip route add default via ${outbound_gw} table ${inbound_table}
echo "${inbound_gw} table ${outbound_table}"
ip route add default via ${inbound_gw} table ${outbound_table}


