#!/bin/bash

docker run --platform linux/amd64 \
  --mount type=bind,source="$(pwd)"/plan.json,target=/plan.json,readonly \
  --mount type=bind,source="$(pwd)"/policies,target=/policies,readonly \
  openpolicyagent/opa:latest-debug
  "exec --decision terraform/analysis/authz --bundle policies plan.json"
