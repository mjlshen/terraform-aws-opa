# terraform-aws-opa

This repository demonstrates how one could write rules in Rego and decide to accept or deny a terraform plan using Open Policy Agent (OPA). OPA has the ability to evaluate rules on arbitrary JSON or YAML input, which [Terraform supports](https://www.terraform.io/docs/internals/json-format.html#plan-representation).

## Requirements

* Open Policy Agent (OPA)
* Terraform
* AWS credentials to run a `terraform plan` (No resources need to be created)

## Rego structure

`main.rego` distributes rule decisions based on the resources shown in a terraform plan using partial evaluation.

```rego
deny[msg] {
  msg := data.terraform[type].deny[_] with input.changesets as changes_by_type[type]
}

deny[msg] {
  msg := data.terraform.aws.common.deny[_]
}
```

The first rule passes specific resources along to a specific matching policy (if it exists). For example, if a terraform plan contains an `aws_s3_bucket` resource, the first rule will delegate its deny decision to data.terraform.aws_s3_bucket, which is contained in `aws_s3_bucket.rego`. The idea is that any specific policies for specific resources can be organized in this fashion. If there is no existing policy for a given resource, OPA makes no decision and no deny message is given.

The second rule passes the entire terraform plan to the policy contained in `aws_common.rego`, which can be used to evaluate resource-agnostic policies, such as a tagging strategy or security baseline.

## Viewing results

Once you have installed OPA and Terraform as well as setup Terraform to be able to at least run a `terraform plan` against an AWS account, these are the commands needed to run the demo yourself.

```bash
terraform init
terraform plan --out tfplan.bin && terraform show -json tfplan.bin > input.json
opa eval --format pretty --data policy/ --input input.json "data.main.deny" --fail-defined
```

The `--fail-defined` flag causes OPA to return an exit code of 1 if `data.main.deny` is non-empty and an exit code of 0 otherwise. Therefore, this series of commands can be used in a CI/CD pipeline to enforce certain organizational policies after writing then out in Rego.

The provided main.tf will generate the following deny message:

```json
[
  "restrict_public_buckets must be true",
  "Cannot use aws_secretsmanager_secret_version - aws_secretsmanager_secret_version.first",
  "Cannot use aws_secretsmanager_secret_version - data.aws_secretsmanager_secret_version.second",
  "aws_secretsmanager_secret_version.first invalid, cannot use resource type aws_secretsmanager_secret_version",
  "data.aws_secretsmanager_secret_version.second invalid, cannot use resource type aws_secretsmanager_secret_version",
  "aws_s3_account_public_access_block.standard is missing required tags: apm_id, dept, environment",
  "aws_secretsmanager_secret.example is missing required tags: apm_id, dept, environment",
  "aws_secretsmanager_secret_version.first is missing required tags: apm_id, dept, environment",
  "aws_s3_account_public_access_block.standard is not a module",
  "aws_s3_bucket.test is not a module",
  "aws_secretsmanager_secret.example is not a module",
  "aws_secretsmanager_secret_version.first is not a module"
]
```

## References

* [Policy-based infrastructure guardrails with Terraform and OPA](https://blog.styra.com/blog/policy-based-infrastructure-guardrails-with-terraform-and-opa)
* [OPA Other Use Cases - Terraform](https://www.openpolicyagent.org/docs/latest/terraform)
* [Partial Evaluation](https://blog.openpolicyagent.org/partial-evaluation-162750eaf422)

