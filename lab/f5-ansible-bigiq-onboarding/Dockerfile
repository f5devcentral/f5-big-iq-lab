FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y python python-dev python-pip python-jmespath && \
    apt-get install -y openssh-client iputils-ping sshpass

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install ansible==2.8.4

COPY ansible.cfg /etc/ansible/ansible.cfg

RUN ansible-galaxy install f5devcentral.f5ansible,master
RUN ansible-galaxy install f5devcentral.bigiq_onboard,master
RUN ansible-galaxy install f5devcentral.register_dcd,master