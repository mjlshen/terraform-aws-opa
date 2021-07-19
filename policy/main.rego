package main

import data.terraform.util.changes_by_type

deny[msg] {
	msg := data.terraform[type].deny[_] with input.changesets as changes_by_type[type]
}

deny[msg] {
	msg := data.terraform.aws.common.deny[_]
}
