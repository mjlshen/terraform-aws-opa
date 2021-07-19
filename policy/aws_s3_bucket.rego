package terraform.aws_s3_bucket

import data.terraform.util.changes_by_type
import data.terraform.util.is_create_or_update
import data.terraform.util.tfplan_resources

resource_type := "aws_s3_bucket"

# Data classification + KMS Key
deny[msg] {
  changeset := changes_by_type[resource_type][_]
  is_create_or_update(changeset.change.actions)

  changeset.change.after.tags.data_classification == "highly-confidential"
  changeset.change.after.server_side_encryption_configuration[_].rule[_].apply_server_side_encryption_by_default[_].kms_master_key_id == null

  msg := sprintf("%v has highly-confidential data and needs a kms_key_id", [changeset.address])
}

# Missing Public S3 Access Block
deny["Missing Public S3 Access Block"] {
  some path, value
  walk(input, [path, value])
  rs := tfplan_resources(path, value)

  rs[_].type == "aws_s3_account_public_access_block"
  rs[_].values.block_public_acls != true
  rs[_].values.block_public_policy != true
  rs[_].values.ignore_public_acls != true
  rs[_].values.restrict_public_buckets != true
}
