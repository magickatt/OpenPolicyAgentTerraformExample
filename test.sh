#!/bin/bash

# Check if the Variable representing all applicable Rules is true/false
opa eval --input plan.json --data policies/ data.enforce_policies.allow | jq '.result[0].expressions[0].value' --raw-output --exit-status &>/dev/null
OPA_EVALUATION="$?"

# If the evaluation fails, provide more information to explain why
if [ "$OPA_EVALUATION" -ne 0 ]; then
    echo -e "Terraform plan violates provided Open Policy Agent policies.\n"
    echo -e "Reasons\n-------------------------"

    # Re-evaluate the policies to determine why they may have failed
    opa eval --input plan.json --data policies/ data.enforce_policies.debug  | jq '.result[0].expressions[0].value | join("\n")' --raw-output
    exit $OPA_EVALUATION

# Otherwise the Terraform plan complies with all evaluated policies
else
    echo "Terraform plan passes provided Open Policy Agent policies."
fi
