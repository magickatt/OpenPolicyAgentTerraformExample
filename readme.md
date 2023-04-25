# Open Policy Agent example using Terraform

Simple example of how to use [Open Policy Agent with Terraform](https://www.openpolicyagent.org/docs/latest/terraform/) including setting up a [GitHub Action](https://github.com/open-policy-agent/setup-opa).

The Agent can either be run as an API (that you can query) or in standalone mode (via the command line) and requires 3 things

* Policies
* Input
* Query

Documentation does not explain particularly well (for a newcomer) what each part of the supplied commands do, so please find a breakdown below. Additionally there is a [slightly easier-to-read explanation](https://spacelift.io/blog/what-is-open-policy-agent-and-how-it-works#how-does-opa-work) of how OPA works. Here we will be looking at evaluating multiple Rules using a Query.

## Contents
* [Quick example](#quick-example)
* [What is a Policy?](#what-is-a-policy)
* [What is a Rule?](#what-is-a-rule)
* [How are Rules evaluated in a Policy?](#how-are-rules-evaluated-in-a-policy)
* [How do you Query a Rule?](#how-do-you-query-a-rule)
* [How do you Query multiple Rules at once?](#how-do-you-query-multiple-rules-at-once)

## Quick example

`main.tf` and `plan.json` are taken from the [provided documentation](https://www.openpolicyagent.org/docs/latest/) (and are not based on any real infrastructure) purely to demonstrate how Open Policy Agent can be run within a container and subsequently the [GitHub Action](https://github.com/open-policy-agent/setup-opa).

You can run the provided Bash script if you have [Open Policy Agent installed locally](https://www.openpolicyagent.org/docs/latest/#1-download-opa), or alternatively there is a provided Dockerfile to run the script in a container, mounting the appropriate files.

```bash
./test.sh

Terraform plan passes provided Open Policy Agent policies.
```

The Docker example is simplified, so please run test.sh locally to see an example of how to provide feedback on which rules deny.

```bash
./docker.sh

Does the Terraform plan comply with the provided Open Policy Agent policies?
true
```

## What is a Policy?

A Policy is simply a collection of Rules. Open Policy Agent will usually evaluate multiple Policies at once, called a Bundle (of Policies)

By convention these are usually in a directory called `policy`. Policies are written in [Rego DSL](https://www.openpolicyagent.org/docs/latest/policy-language/).

## What is a Rule?

Rules are essentially declarations in a policy (similar to a variable or constant definition) that are evaluated at runtime. They are usually evaluated against Input.

Basic example is a hello rule that will evaluate to true if the Input contains a message key with a value world

```rego
hello if input.message == "world
```

You can test this rule out at the [Rego Playground](https://play.openpolicyagent.org/).

## How are Rules evaluated in a Policy?

All Rules in a Policy, and all Policies in a Bundle are evaluated at runtime. Policies are specified using the data flag, so you will usually see it passed as something like  `--data policy/`

## How do you provide Input?

Input must be JSON, and is often either passed as a file/stream using the input flag (on the command line) or in the request body for the API. For the command line you will see it passed as something like `--input plan.json`

## How do you Query a Rule?

You can only specific 1 Query per run, which usually means you will check a single Rule in a Policy.

```rego
opa eval --input plan.json --data policy/ data.enforce_policies.allow
```

Policies can be accessed as `data.*` so you can access the allow Rule in the `enforce_policies` Package, which will be in 1 of the Policies supplied.

## How do you Query multiple Rules at once? 

Querying 1 Rule at a time is often not very useful, so you can create a Rule that queries other Rules. 

```rego
are_we_good {
    score < blast_radius
    not touches_iam
}
```

In this example, the `are_we_good` Rule is evaluated based on the score, `blast_radius` and `touches_iam` Rules. Remember that Rules are similar to variables/constants, so in this case score and `blast_radius` contain integers and `touches_iam` is a boolean.

`score < blast_radius` also evaluates as a boolean, so the `are_we_good` Rule evaluates to true if both those statements evaluate to true. Usually multi-line Rules evaluate using AND logic (each line must evaluate to true for the Rule to be true)

Of course this gets more complicated with different data types, but hopefully this provides an idea of how you can gradually build up Rules for your own Policies.

## Writing unit tests

Like any other code, it should have tests to prove it works as intended. Instead of user-supplied Input, you can supply it inline (wrappers such as conftest allow loading fixtures from files)

```rego
test_not_allowed_if_is_pizza if {
    not is_burger with input as {"order":"pizza"}
}
```

Sample unit tests can be found in `policies/combined_test.rego` noting that OPA will look for unit tests in `*_test.rego` files, therefore `combined_test.rego` contains tests for `combined.rego`. Tests should use the same Packages as the Rules that they are tested (so `combined.rego` and `combined_test.rego` both use the Package `package enforce_policies`)

The overall Rule that we query is `enforce_policies.allow` (the allow Rule in the overall Package) which can be found in `policy/combined.rego`. It should additionally validate Rules from other Policies, so please add/update Rules in other Packages and include them as necessary.

If evaluating `enforce_policies.allow` fails, then a subsequent Query will be made to `enforce_policies.deny` to show what Rules were broken which caused the Terraform plan to not comply to our Policies. These use [Partial Rules to build up a list of error messages.](https://blog.openpolicyagent.org/rego-design-principle-1-syntax-should-reflect-real-world-policies-e1a801ab8bfb)

```rego
deny[message] {
    not data.example.is_burger
    message := "Only burgers are allowed"
}
```

Please note you must update both `allow` and `deny` with any new Rules, otherwise you may get Terraform plans which are denied but no explanation as to why.
