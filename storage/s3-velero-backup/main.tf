locals {
  account_id      = element(split(":", var.aws_assume_role_arn), 4)
  velero_role_arn = var.velero_role_arn != null ? var.velero_role_arn : format("arn:aws:iam::%s:role/VeleroBackup", local.account_id)
  bucket_arn      = format("arn:aws:s3:::%s", var.bucket_name)
}

data "aws_iam_policy_document" "policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [local.velero_role_arn]
    }

    sid     = "Bucket permissions"
    effect  = "Allow"
    actions = ["s3:*"]

    resources = [
      local.bucket_arn,
      "${local.bucket_arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.policy.json
}

module "velero_storage" {
  source                              = "../../_sub/storage/s3-bucket-lifecycle"
  name                                = var.bucket_name
  retention_days                      = var.retention_days
  policy                              = data.aws_iam_policy_document.policy.json
  additional_tags                     = var.additional_tags
  replication_enabled                 = var.replication_enabled
  replication_source_role_arn         = var.replication_source_role_arn
  replication_destination_account_id  = var.replication_destination_account_id
  replication_destination_bucket_arn  = var.replication_destination_bucket_arn
  replication_destination_kms_key_arn = var.replication_destination_kms_key_arn
  versioning_enabled                  = true
}
