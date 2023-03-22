package enforce_policies
import data.opa_terraform_example
import data.additional_example

# Only pass the policy if all the imported checks evaluate to true.
allow = true {
  opa_terraform_example.authz == true
  additional_example.something == true
}
# package enforce_policies
hello := true