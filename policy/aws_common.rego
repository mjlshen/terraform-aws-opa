package terraform.aws.common

import data.terraform.util.contains_resource
import data.terraform.util.resources
import data.terraform.util.tfplan_resources

allowed_environments := [
	"sandbox",
	"development",
	"qa",
	"pvs",
	"staging",
	"production",
]

required_resources := [
  "aws_s3_account_public_access_block"
]

denied_resources := [
  "aws_secretsmanager_secret_version"
]

# Using a denied resource
deny[msg] {
  some i
  contains_resource(denied_resources[i])
  rs := resources(denied_resources[i])

  msg := sprintf("%v invalid, cannot use resource type %v", [
    rs[_].address,
    denied_resources[_]
  ])
}

# Provider must start with "registry.terraform.io/hashicorp/*"
deny[msg] {
	p := split(providers[_], "/")
	p[0] != "registry.terraform.io"

	count(p) > 0

	msg := sprintf("Must use providers from registry.terraform.io: %v", [p])
}

deny[msg] {
	p := split(providers[_], "/")
	p[1] != "hashicorp"

	count(p) > 0

	msg := sprintf("Must use providers from hashicorp: %v", [p])
}

# Missing required resource
deny["Missing aws_s3_account_public_access_block resource"] {
  some i
	not contains_resource(required_resources[i])

  msg := sprintf("Missing required resource %v", [
    required_resources[i]
  ])
}

# Missing required tags
deny[msg] {
	changeset := input.resource_changes[_]
	changeset.provider_name == "registry.terraform.io/hashicorp/aws"
  split(changeset.address, ".")[0] != "data"

	required_tags := {"apm_id", "dept", "environment"}
	provided_tags := {tag | changeset.change.after.tags_all[tag]}
	missing_tags := required_tags - provided_tags

	count(missing_tags) > 0

	msg := sprintf("%v is missing required tags: %v", [
		changeset.address,
		concat(", ", missing_tags),
	])
}

# Invalid environment tag
deny[msg] {
	changeset := input.resource_changes[_]

	not valid_tag(changeset.change.after.tags.environment, allowed_environments)
	msg := sprintf("%v has an invalid environment tag: %v", [
		changeset.address,
		changeset.change.after.tags.environment,
	])
}

# Non-module/data objects
deny[msg] {
	changeset := input.resource_changes[_]
	changeset.provider_name == "registry.terraform.io/hashicorp/aws"

	split(changeset.address, ".")[0] != "module"
	split(changeset.address, ".")[0] != "data"
	changeset.mode == "managed"

	msg := sprintf("%v is not a module", [changeset.address])
}

valid_tag(tag, values) {
	tag == values[_]
}

providers = {rs[i].address: rs[i].provider_name |
	some path, value
	walk(input, [path, value])
	rs := tfplan_resources(path, value)
}
