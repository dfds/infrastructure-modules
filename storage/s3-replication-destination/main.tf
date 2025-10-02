locals {
  bucket_arn = format("arn:aws:s3:::%s", var.bucket_name)
}

module "destination" {
  source             = "../../_sub/storage/s3-bucket-lifecycle"
  bucket_name        = var.bucket_name
  bucket_policy      = data.aws_iam_policy_document.policy.json
  sse_algorithm      = var.sse_algorithm
  versioning_enabled = true
}

data "aws_iam_policy_document" "policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.replication_role_arn]
    }

    sid    = "ReplicationPermissions"
    effect = "Allow"
    actions = [
      "s3:ReplicateDelete",
      "s3:ReplicateObject",
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning"
    ]

    resources = [local.bucket_arn, format("%s/*", local.bucket_arn)]

  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.policy.json

  depends_on = [
    module.destination
  ]
}
