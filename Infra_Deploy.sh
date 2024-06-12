#!/bin/bash
#deploy base infrastructure
# example run command
# . ./Infra_Deploy.sh $bamboo_deploy_environment $@
# . ./Infra_Deploy.sh PROD $@
#
# For one time ansible script
# . ./Infra_Deploy.sh PROD "security_groups" "vars/security_groups.var.yml"

#ensure we die if any function fails
set -e

VARS_FILE="vars/shared.var.yml"
ENVIRONMENT="$1"
ANSIBLE_EXTRA_VARS="$ANSIBLE_EXTRA_VARS Environment=$ENVIRONMENT"

set -x

run-playbook () {
  if [ -z "$2" ]; then
    unset VARS_FILE_2
  elif [ -e "$2" ]; then
    VARS_FILE_2="--extra-vars @$2"
  else
    VARS_FILE_2="--extra-vars $2"
  fi
  PLAYBOOK="$1"
  if [ ! -e "$PLAYBOOK" ]; then
    PLAYBOOK="$PLAYBOOK.yml"
  fi
  ansible-playbook -i inventory/hosts "$PLAYBOOK" --extra-vars "@$VARS_FILE" $VARS_FILE_2 --extra-vars "$ANSIBLE_EXTRA_VARS" -vvv
}

run-shared-resource-playbooks () {
  run-playbook "CloudFormation" "vars/iam.var.yml"
  run-playbook "CloudFormation" "vars/iam-instance.var.yml"
  run-playbook "vpc"
  run-playbook "CloudFormation" "vars/security_groups.var.yml"
  run-playbook "cloudfront_security_groups"

}

run-deployment () {
  echo "Run-deployment goes here"
}

run-all-playbooks () {
  run-shared-resource-playbooks
  run-deployment
}

if [ $# -ge 2 ]; then
  if [ "$2" = "deploy" ]; then
    run-deployment
  else
    # run custom playbook
    run-playbook "$2" "$3"
  fi
else
  run-all-playbooks
fi
