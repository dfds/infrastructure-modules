# tfsec:ignore:AVD-AWS-0089 tfsec:ignore:AVD-AWS-0090
resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# tfsec:ignore:AVD-AWS-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = var.acl

  depends_on = [
    aws_s3_bucket_public_access_block.block_public_access,
    aws_s3_bucket_ownership_controls.bucket_ownership_controls,
  ]
}

resource "aws_s3_bucket_versioning" "bucket" {
  count  = length(var.replication) > 0 || var.versioning_enabled ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  count  = var.lifecycle_enabled ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "lifecycle_policy"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = var.retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.retention_days
    }

    expiration {
      days = var.retention_days
    }
  }
}

data "aws_iam_policy_document" "replication_role_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com", "batchoperations.s3.amazonaws.com"]
    }
  }
}

locals {
  destination_bucket_arns = [for r in values(var.replication) : r.destination_bucket_arn]
  kms_encryption_key_arns = [
    for r in values(var.replication) : r.kms_encryption_key_arn
    if r.kms_encryption_key_arn != ""
  ]
}

# In order to use the replication role, we need to create a policy that allows the source bucket to replicate objects to the destination bucket.
# This policy must be attached to the source bucket's IAM role.
# However, in order to avoid a circular dependency, we need to create the policy and role first before replication can be enabled.
data "aws_iam_policy_document" "replication_policy" {
  statement {
    sid    = "SourceBucketPermissions"
    effect = "Allow"
    resources = [
      format("arn:aws:s3:::%s/*", var.bucket_name),
      format("arn:aws:s3:::%s", var.bucket_name)
    ]
    actions = [
      "s3:GetObjectRetention",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionAcl",
      "s3:ListBucket",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectLegalHold",
      "s3:GetReplicationConfiguration"
    ]
  }

  dynamic "statement" {
    for_each = length(local.destination_bucket_arns) > 0 ? [1] : []
    content {
      sid       = "DestinationBucketPermissions"
      effect    = "Allow"
      resources = formatlist("%s/*", local.destination_bucket_arns)
      actions = [
        "s3:ReplicateObject",
        "s3:ObjectOwnerOverrideToBucketOwner",
        "s3:GetObjectVersionTagging",
        "s3:ReplicateTags",
        "s3:ReplicateDelete"
      ]
    }
  }

  dynamic "statement" {
    for_each = length(local.kms_encryption_key_arns) > 0 ? [1] : []
    content {
      sid       = "KMSPermissions"
      effect    = "Allow"
      resources = local.kms_encryption_key_arns
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey",
        "kms:DescribeKey"
      ]
    }
  }
}

resource "aws_iam_role" "replication_role" {
  name               = "S3Replication-${var.bucket_name}"
  assume_role_policy = data.aws_iam_policy_document.replication_role_trust_policy.json
}

resource "aws_iam_policy" "replication_policy" {
  name   = "S3ReplicationPolicy-${var.bucket_name}"
  policy = data.aws_iam_policy_document.replication_policy.json
}

resource "aws_iam_role_policy_attachment" "replication_policy_attachment" {
  role       = aws_iam_role.replication_role.name
  policy_arn = aws_iam_policy.replication_policy.arn
}

resource "aws_s3_bucket_replication_configuration" "bucket_replication" {
  count  = length(var.replication) > 0 ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  role   = aws_iam_role.replication_role.arn

  dynamic "rule" {
    for_each = var.replication
    content {
      id       = "replication_rule_${rule.key}"
      status   = "Enabled"
      priority = index(keys(var.replication), rule.key)

      filter {}

      destination {
        access_control_translation {
          owner = "Destination"
        }

        account = rule.value["destination_account_id"]
        bucket  = rule.value["destination_bucket_arn"]

        dynamic "encryption_configuration" {
          for_each = rule.value["kms_encryption_key_arn"] != "" ? [1] : []
          content {
            replica_kms_key_id = rule.value["kms_encryption_key_arn"]
          }
        }
      }

      dynamic "source_selection_criteria" {
        for_each = rule.value["kms_encryption_key_arn"] != "" ? [1] : []
        content {
          sse_kms_encrypted_objects {
            status = "Enabled"
          }
        }
      }

      delete_marker_replication {
        status = "Enabled"
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.bucket]
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = var.bucket_policy
}
