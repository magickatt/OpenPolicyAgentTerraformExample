package enforce_policies
import data.opa_terraform_example
import data.additional_example

# Only pass the policy if all the imported checks evaluate to true.
# default allow := false
allow = true {
  opa_terraform_example.authz == true
  additional_example.something == true
}

information = output {
#   output := [ "pizza", data.opa_terraform_example.touches_iam, "hello" ]
    output := [data.opa_terraform_example.does_touch_kms, data.opa_terraform_example.num_deletes, modified_iam_resources, blast_radius_impact]
#   touches_iam := data.opa_terraform_example.touches_iam
#   score_exceeds_blast_radius := data.opa_terraform_example.score > data.opa_terraform_example.blast_radius
}

modified_iam_resources[resource] {
    resource := data.opa_terraform_example.resources["aws_iam"]
}

blast_radius_impact := sprintf("Sample message, score is %d, blast radius is %d", [data.opa_terraform_example.score, data.opa_terraform_example.blast_radius])

debug[message] {
    data.opa_terraform_example.score > data.opa_terraform_example.blast_radius
    message := "Score exceeds blast radius"
}

debug[message] {
    not data.opa_terraform_example.touches_iam
    message := "IAM modifications are not allowed"
}

# package enforce_policies
hello := true
