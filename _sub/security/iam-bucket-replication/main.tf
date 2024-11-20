locals {
  replication_source_bucket_arns      = concat([var.replication_source_bucket_arn], formatlist("%s/*", var.replication_source_bucket_arn))
  replication_destination_bucket_arns = concat(formatlist("%s/*", var.replication_destination_bucket_arn))
  policy_name                         = var.replication_source_role_name
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "SourceBucketPermissions"
    effect = "Allow"

    resources = local.replication_source_bucket_arns

    actions = [
      "s3:GetObjectLegalHold",
      "s3:GetObjectRetention",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionTagging",
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
  }

  statement {
    sid       = "DestinationBucketPermissions"
    effect    = "Allow"
    resources = local.replication_destination_bucket_arns

    actions = [
      "s3:GetObjectVersionTagging",
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:ReplicateDelete",
      "s3:ReplicateObject",
      "s3:ReplicateTags"
    ]
  }

  statement {
    sid       = "SourceBucketKMSKey"
    effect    = "Allow"
    resources = [var.replication_source_kms_key_arn]

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]
  }

  statement {
    sid       = "DestinationBucketKMSKey"
    effect    = "Allow"
    resources = [var.replication_destination_kms_key_arn]

    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey",
    ]
  }
}

resource "aws_iam_policy" "this" {
  name   = local.policy_name
  path   = "/"
  policy = data.aws_iam_policy_document.this.json
  tags   = var.tags
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.replication_source_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
