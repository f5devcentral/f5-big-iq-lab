#!/bin/bash
echo "Change gateway to SSLo Paris as Default Gateway"
ip route change default via 10.1.20.13 dev eth2
sleep 2s
echo "Generate traffic through SSLo Paris"
count=1
while [ $count -le 30 ]
do
curl -k https://www.chase.com
curl -k https://www.f5.com
curl -k https://www.youtube.com
curl -k https://www.facebook.com
curl -k https://www.nginx.com
curl -k https://hackazon.paris.f5se.com
curl -k https://www.perdu.com
curl -k https://www.health.com
curl -k https://www.harley-davidson.com/fr/fr/index.html
((count++))
done

echo "Change gateway to SSLo Seattle as Default Gateway"
ip route change default via 10.1.20.7 dev eth2
sleep 2s
echo "Generate traffic through SSLo Paris"
count=1
while [ $count -le 30 ]
do
curl -k https://mabanque.bnpparibas
curl -k https://www.f5.com
curl -k https://www.suresnes.fr
curl -k https://www.youtube.com
curl -k https://harobikes.com/pages/bmx
curl -k https://www.suunto.com
curl -k https://www.ford.fr
curl -k https://www.harley-davidson.com/fr/fr/index.html
((count++))
done


echo "Change gateway to default gateway"
ip route change default via 10.1.1.2 dev eth0
