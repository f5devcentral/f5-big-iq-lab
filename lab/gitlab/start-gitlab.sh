#!/bin/bash
# Uncomment set command below for code debuging bash
#set -x

# cleanup old ssh keys
ssh-keygen -f "/home/f5student/.ssh/known_hosts" -R "[localhost]:7022"

GITLAB_HOME="~/gitlab/" docker-compose -f ~/gitlab/docker-compose.yml up -d

secs=120
while [ $secs -gt 0 ]; do
        echo -ne "$secs\033[0K\r"
        sleep 1
        : $((secs--))
done

docker exec gitlab_gitlab_1 update-permissions
sleep 5
docker restart gitlab_gitlab_1

secs=30
while [ $secs -gt 0 ]; do
        echo -ne "$secs\033[0K\r"
        sleep 1
        : $((secs--))
done

docker logs gitlab_gitlab_1

echo -e "To continue monitor GitLab starting, run:\n\ndocker logs gitlab_gitlab_1\n" 