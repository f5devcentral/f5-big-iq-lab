#!/bin/bash
# Uncomment set command below for code debugging bash
#set -x
# Uncomment set command below for code debugging ansible
#DEBUG_arg="-vvvv"

ansible-playbook -i notahost, create_http_bigiq_app.yaml $DEBUG_arg
