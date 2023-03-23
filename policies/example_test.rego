package opa_terraform_example

import future.keywords

test_allowed_if_no_aws_iam_changes if {
    not touches_iam with input as {"resource_changes":[{"type":"aws_launch_configuration"}]}
}

test_not_allow_if_there_are_aws_iam_changes if {
   touches_iam with input as {"resource_changes":[{"type":"aws_iam"}]}
}
