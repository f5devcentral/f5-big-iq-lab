#!/bin/bash

# add small delay to the install
sleep 120
##### Install Artiom's awesome Demo App #####
# install Docker
apt-get -y install docker.io
# Spin up Docker Instances

# Hackazon for AS3 with WAF:
docker run --restart=unless-stopped --name=hackazon -d -p 80:80 mutzel/all-in-one-hackazon:postinstall supervisord -n
# F5-Hello-World for HTTP Sites:
docker run --restart=unless-stopped --name=f5-hello-world-blue -dit -p 8081:8080 -e NODE='Blue' f5devcentral/f5-hello-world
docker run --restart=unless-stopped --name=f5-hello-world-green -dit -p 8082:8080 -e NODE='Green' f5devcentral/f5-hello-world
# DVWA for f5.http iApp with WAF:
docker run --restart=unless-stopped --name=dvwa -d -p 8080:80 infoslack/DVWA