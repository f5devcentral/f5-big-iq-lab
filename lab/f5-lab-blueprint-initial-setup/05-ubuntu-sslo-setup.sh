##### SSLo Service Inline L3

# Subnet 30 (SSLo Inline L3 IN)
# 10.1.30.0/24
# eth1: 10.1.30.14

# Subnet 40 (SSLo Inline L3 OUT)
# 10.1.40.0/24
# eth2: 10.1.40.14

echo "auto eth1
iface eth1 inet static
   address 10.1.30.14
   netmask 255.255.255.0

auto eth2
iface eth2 inet static
   address 10.1.40.14
   netmask 255.255.255.0
   gateway 10.1.40.7" > /etc/network/interfaces

echo "0" > /proc/sys/net/ipv4/ip_forward

cat > /etc/iptables.rules
iptables -A FORWARD -i eth2 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT
iptables -L
iptables-save > /etc/iptables.rules
iptables-save

# Run sslo/setup-l3a.sh

##### SSLo Service TAP

# Subnet 50 (SSLo TAP)
# 10.1.50.0/24
# eth1: 10.1.50.50

# There is a script which update the Mac address on both BIG-IP Paris and Seattle.
# More details: https://github.com/f5devcentral/f5-big-iq-lab/blob/develop/lab/scripts/sslo/update_mac_tap.sh
