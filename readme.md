# Open Policy Agent example using Terraform

Simple example of how to use [Open Policy Agent with Terraform](https://www.openpolicyagent.org/docs/latest/terraform/) including setting up a [GitHub Action](https://github.com/open-policy-agent/setup-opa). This should help explain the following concepts...

* What is a Policy?
* What is a Rule?
* How are Rules evaluated in a Policy?
* How do you Query a Rule?
* How do you Query multiple Rules at once? 

`main.tf` and `plan.json` are taken from the provided documentation (and are not based on any real infrastructure) purely to demonstrate how Open Policy Agent can be run within a container and subsequently the [GitHub Action](https://github.com/open-policy-agent/setup-opa).

Documentation does not explain particularly well (for a newcomer) what each part of the supplied commands do, so please find a breakdown below. Additionally there is a [slightly easier-to-read explanation](https://spacelift.io/blog/what-is-open-policy-agent-and-how-it-works#how-does-opa-work) of how OPA works. Here we will be looking at evaluating multiple Rules using a Query.

## Quick example

You can run the provided Bash script if you have Open Policy Agent installed locally, or alternatively there is a provided Dockerfile to run the script in a container, mounting the appropriate files.

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

## What is a Rule?
## How are Rules evaluated in a Policy?
## How do you Query a Rule?
## How do you Query multiple Rules at once? 

## Decision

```bash
opa exec --decision 
```

Most examples will show commands such as `opa test` which uses a [subcommand](https://gobyexample.com/command-line-subcommands) such as `test`. However for Terraform, they expect you to determine a "decision" (allowed or not allowed) based on polic(ies), input (Terraform plan file) and query (from a policy in a [remote bundle](https://www.openpolicyagent.org/docs/latest/management-bundles) or 1 of the user-supplied policies, we are doing the latter in this case)

The string argument referenced after `--decision` is the name of a variable in package namespace. In their example, since the package is `terraform.analysis` the argument is for the `authz` boolean, therefore `--decision terraform.analysis.authz`. So you essentially tell OPA __how__ to decide by telling it what variable to inspect.

```bash
opa exec --decision 
```

### Adding description and message to decision output

By default the output from a decision will be fairly basic, simply telling you what input data was evaluated and what the result of the decision was.

```json
{
  "result": [
    {
      "path": "plan.json",
      "result": true
    }
  ]
}
```

For Continuous Integration checks this is not overly useful, so you can supply a description and message if the decision is not successful.

```go
authz[msg] {
    desc := "Sample description"
    msg := sprintf("Sample message, score is %d, blast radius is %d", [score, blast_radius])
    score < blast_radius
    not touches_iam
}
```

### Multiple decisions

If you want to evaluate multiple decisions, you must query each variable separately (referencing their namespaced name) as an additional command line parameter.

```bash
opa exec --decision terraform/analysis/authz \
  --decision terraform/analysis/something \
  --bundle policies/ plan.json
```

An alternative way to potentially do this is to include a file that includes a decision that depends on code evaluations in other files. Provided they are in the same package they should be available.

```go
authz {
    score < blast_radius
    not touches_iam
    something # Referenced from policies/additional.rego
}
```

## Policy bundle

```bash
--bundle policies/
```

Policies are either user-supplied or loaded from a remote bundle. In the provided simple example they provided in a single Rego policy file. Seemingly this will not work if you specify the path to a specific policy file (even if you only have 1) it must be a directory.

## Input data

```bash
plan.json
```

The 1st (and in this case only) positional argument is the input data. It must always be JSON, so for Terraform we need to convert outputted plan files into their JSON representation.
