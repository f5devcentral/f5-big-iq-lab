#!/bin/bash

registration_token=$1
server="10.1.1.5"

# Usage
if [[ -z $registration_token ]]; then
    echo -e "# Specify token ID.\n"
    echo -e "# Get the registration token from:"
    echo -e "# http://localhost:7002/root/${project}/settings/ci_cd"
    exit 1;
fi

docker exec -it gitlab-runner1 \
  gitlab-runner register \
    --non-interactive \
    --registration-token ${registration_token} \
    --locked=false \
    --description docker-stable \
    --url https://${server}:7002 \
    --executor docker \
    --docker-image docker:stable \
    --docker-volumes "/var/run/docker_gitlab.sock:/var/run/docker.sock" \
