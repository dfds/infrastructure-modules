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
  source               = "../../_sub/storage/s3-bucket-lifecycle"
  bucket_name          = var.bucket_name
  bucket_policy        = data.aws_iam_policy_document.policy.json
  replication          = var.replication
  replication_role_arn = var.replication_role_arn
  sse_algorithm        = var.sse_algorithm
  retention_days       = var.retention_days
  versioning_enabled   = true
}
