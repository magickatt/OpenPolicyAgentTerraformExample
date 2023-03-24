#!/bin/bash

echo "Does the Terraform plan comply with the provided Open Policy Agent policies?"
docker run --platform linux/amd64 --mount type=bind,source="$(pwd)"/plan.json,target=/plan.json,readonly \
  --mount type=bind,source="$(pwd)"/policies,target=/policies,readonly \
  --mount type=bind,source="$(pwd)"/test.sh,target=/test.sh,readonly \
  openpolicyagent/opa:latest-debug \
  eval --input plan.json --data policies/ data.enforce_policies.allow | jq '.result[0].expressions[0].value' --raw-output --exit-status
