#!/bin/bash

docker run --platform linux/amd64 \
  openpolicyagent/opa
  "exec --decision terraform/analysis/authz"

opa exec --decision terraform/analysis/authz --bundle policies/ plan.json


opa eval --fail -i plan.json -d policies/example.rego 'data.opa_terraform_example.authz'

opa eval -i plan.json -d policies/ data.enforce_policies.hello
