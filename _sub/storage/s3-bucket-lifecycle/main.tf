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

# TODO: Create a new IAM role for replication
# https://repost.aws/knowledge-center/s3-cross-account-replication-object-lock
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-batch-replication-policies.html

resource "aws_s3_bucket_replication_configuration" "bucket_replication" {
  bucket = aws_s3_bucket.bucket.id
  role   = var.replication_role_arn

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
