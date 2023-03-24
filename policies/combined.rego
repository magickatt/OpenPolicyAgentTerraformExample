package enforce_policies

import data.opa_terraform_example
import data.additional_example

# Open Policy Agent requires a single query, so this "overall" policy represents
# Rules from various other Policies. These are combined into a single "allow"
# Rule below to determine whether the Terraform plan provided either adheres to
# or violates 1 or more Policies.
default allow := false
allow = true {
  opa_terraform_example.authz == true
  additional_example.something == true
}

# Because we are using a combined Rule to evaluate whether the Terraform plan
# adheres to or violates our Policies, we need a way to find out what Rules 
# have been broken. However if you Query the Rules themselves, you will simply 
# get a true/false/null evaluation.
# 
# Way of doing this (as mentioned by Styra's CTO) is to use a Partial Rule to 
# incrementally define the reasons/errors that different Rules are broken. 
# Naming convention is taken from conftest which can be used as a wrapper.
# 
# "a common approach to returning a collection of error messages is to use 
# Rego's partial set to add members to the set of error messages"
# https://blog.openpolicyagent.org/rego-design-principle-1-syntax-should-reflect-real-world-policies-e1a801ab8bfb
# https://www.openpolicyagent.org/docs/latest/policy-language/#incremental-definitions
# https://www.openpolicyagent.org/docs/latest/#partial-rules
# https://www.conftest.dev/#evaluating-policies

debug[message] {
    data.opa_terraform_example.score > data.opa_terraform_example.blast_radius
    message := sprintf("Score (%d) exceeds blast radius (%d)", [data.opa_terraform_example.score, data.opa_terraform_example.blast_radius])
}

debug[message] {
    data.opa_terraform_example.touches_iam
    message := "IAM modifications are not allowed"
}

debug[message] {
    not data.additional_example.something
    message := "Something is false, we cannot have that now can we?"
}
