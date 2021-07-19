package terraform.aws_s3_account_public_access_block

import data.terraform.util.resources

resource_type := "aws_s3_account_public_access_block"

rs := resources(resource_type)

deny["block_public_acls must be true"] {
	rs[_].values.block_public_acls != true
}

deny["block_public_policy must be true"] {
	rs[_].values.block_public_policy != true
}

deny["ignore_public_acls must be true"] {
	rs[_].values.ignore_public_acls != true
}

deny["restrict_public_buckets must be true"] {
	rs[_].values.restrict_public_buckets != true
}
