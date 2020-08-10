FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y python3 python3-dev python3-pip python3-jmespath && \
    apt-get install -y openssh-client iputils-ping sshpass wget

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip3 install ansible

COPY ansible.cfg /etc/ansible/ansible.cfg

RUN ansible-galaxy install f5devcentral.atc_deploy --force
#RUN ansible-galaxy install f5devcentral.bigiq_pinning_deploy_objects --force
RUN ansible-galaxy install rjouhann.bigiq_pinning_deploy_objects --force

RUN ansible-galaxy collection install f5networks.f5_modules