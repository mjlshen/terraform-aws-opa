package terraform.aws_security_group_rule

import data.terraform.util.is_create_or_update
import data.terraform_util.changes_by_type

resource_type := "aws_security_group_rule"

# Deny 0.0.0.0/0 ingress
deny[msg] {
  changeset := changes_by_type[resource_type][_]
  is_create_or_update(changeset.change.actions)

  changeset.change.after.type == "ingress"
  changeset.change.after.cidr_blocks[_] == "0.0.0.0/0"

  msg := sprintf("%v has 0.0.0.0/0 as allowed ingress", [changeset.address])
}
