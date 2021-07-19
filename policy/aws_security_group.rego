package terraform.aws_security_group

import data.terraform.util.changes_by_type
import data.terraform.util.is_create_or_update

resource_type := "aws_security_group"

deny[msg] {
  changeset := changes_by_type[resource_type][_]
  is_create_or_update(changeset.change.actions)

  changeset.change.after.ingress
  msg := sprintf("%v has an ingress that should be a security group rule instead", [changeset.address])
}

deny[msg] {
  changeset := changes_by_type[resource_type][_]
  is_create_or_update(changeset.change.actions)

  changeset.change.after.egress
  msg := sprintf("%v has an egress that should be a security group rule instead", [changeset.address])
}
