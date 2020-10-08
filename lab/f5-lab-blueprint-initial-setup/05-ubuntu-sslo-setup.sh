##### SSLo Service Inline L3

# Subnet 30 (SSLo Inline L3 IN)
# 10.1.30.0/24
# eth1: 10.1.30.14

# Subnet 40 (SSLo Inline L3 OUT)
# 10.1.40.0/24
# eth2: 10.1.40.14

echo 'network:
  version: 2
  ethernets:
    ens6:
        addresses:
            - 10.1.30.14/24
    ens7:
        addresses:
            - 10.1.40.14/24
        gateway4: 10.1.40.7' > /etc/netplan/01-netcfg.yaml

netplan generate
netplan try

cat /proc/sys/net/ipv4/ip_forward
echo "0" > /proc/sys/net/ipv4/ip_forward

iptables -A FORWARD -i eth2 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT
iptables -L
iptables-save > /etc/iptables.rules
iptables-save
cat /etc/iptables.rules

# Run script sslo/setup-l3a.sh

##### SSLo Service TAP

# Subnet 50 (SSLo TAP)
# 10.1.50.0/24
# eth1: 10.1.50.50

# There is a script which update the Mac address on both BIG-IP Paris and Seattle.
# More details: https://github.com/f5devcentral/f5-big-iq-lab/blob/develop/lab/tools/update_mac_sslo_tap.sh
