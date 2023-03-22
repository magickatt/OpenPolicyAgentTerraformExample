package enforce_policies
import data.opa_terraform_example
import data.additional_example

# Only pass the policy if all the imported checks evaluate to true.
default allow := false
allow = true {
  opa_terraform_example.authz == true
  additional_example.something == true
}

# information = output {
#     output := [data.opa_terraform_example.does_touch_kms, data.opa_terraform_example.num_deletes, modified_iam_resources, blast_radius_impact]
# }

# modified_iam_resources[resource] {
#     resource := data.opa_terraform_example.resources["aws_iam"]
# }

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
