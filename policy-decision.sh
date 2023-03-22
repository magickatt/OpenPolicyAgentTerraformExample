#!/bin/bash

# Run this image forcing x86 architecture (only some images are built multi-architecture)
# Mount the JSON input (converted Terraform plan file in this example)
# Mount the Rego policy directory
# Execute a decision from a policy (authz variable in the terraform/analysis package) 
# ... in a local bundle (directory) using local input (JSON file)
docker run --platform linux/amd64 \
  --mount type=bind,source="$(pwd)"/plan.json,target=/plan.json,readonly \
  --mount type=bind,source="$(pwd)"/policies,target=/policies,readonly \
  openpolicyagent/opa:latest-debug \
  exec --decision terraform/analysis/authz --bundle policies plan.json
