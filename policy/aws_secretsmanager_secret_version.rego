package terraform.aws_secretsmanager_secret_version

import data.terraform.util.contains_resource
import data.terraform.util.resources

resource_type := "aws_secretsmanager_secret_version"

rs := resources(resource_type)

deny[msg] {
  contains_resource(resource_type)

  msg := sprintf("Cannot use aws_secretsmanager_secret_version - %v", [
    rs[_].address
  ])
}