#!/bin/bash
# what is needed to run inside aws cloudshell

pip install ansible
ansible-galaxy collection install community.aws

#then
# ./Infra_deploy.sh PROD
