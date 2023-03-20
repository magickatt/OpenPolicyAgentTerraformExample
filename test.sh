#!/bin/bash

docker run --platform linux/amd64 \
  openpolicyagent/opa
  "exec --decision terraform/analysis/authz"

opa exec --decision terraform/analysis/authz --bundle policies/ plan.json
