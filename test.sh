#!/bin/bash

opa eval --input plan.json --data policies/ data.enforce_policies.allow | jq '.result[0].expressions[0].value' --raw-output --exit-status &>/dev/null
if [ "$?" -ne 0 ]; then
    echo "Terraform plan violates provided Open Policy Agent policies."
    exit $?
else
    echo "Terraform plan passes provided Open Policy Agent policies."
fi