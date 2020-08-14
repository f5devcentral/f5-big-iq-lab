#!/bin/bash

registration_token=$1
server="10.1.1.5"
project="mywebapp"

# Usage
if [[ -z $registration_token ]]; then
    echo -e "\n# Specify token ID."
    echo -e "# Get the registration token from:"
    echo -e "# http://localhost:7002/root/${project}/settings/ci_cd\n"
    exit 1;
fi

docker exec -it gitlab-runner1 \
  gitlab-runner register \
    --non-interactive \
    --registration-token ${registration_token} \
    --locked=false \
    --description docker-stable \
    --url http://${server}:7002 \
    --executor docker \
    --docker-image docker:stable \
    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
