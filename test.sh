#!/bin/bash

# Prevent GitHub Action from exiting early
set +e pipefail

# Check if the Variable representing all applicable Rules is true/false
opa eval --input plan.json --data policies/ data.enforce_policies.allow | jq '.result[0].expressions[0].value' --raw-output --exit-status &>/dev/null
OPA_EVALUATION="$?"

# If the evaluation fails, provide more information to explain why
if [ "$OPA_EVALUATION" -ne 0 ]; then
    echo "Terraform plan violates provided Open Policy Agent policies."
    exit $OPA_EVALUATION
else
    echo "Terraform plan passes provided Open Policy Agent policies."
fi
