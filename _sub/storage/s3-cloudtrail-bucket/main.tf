resource "aws_s3_bucket" "log_bucket" {
  count  = var.create_s3_bucket && var.s3_log_bucket != null ? 1 : 0
  bucket = var.s3_log_bucket
  tags = {
    "Managed by" = "Terraform"
  }

  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "log_bucket_ownership_controls" {
  count  = var.create_s3_bucket && var.s3_log_bucket != null ? 1 : 0
  bucket = aws_s3_bucket.log_bucket[count.index].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  count  = var.create_s3_bucket && var.s3_log_bucket != null ? 1 : 0
  bucket = aws_s3_bucket.log_bucket[count.index].id
  acl    = "log-delivery-write"

  depends_on = [aws_s3_bucket_ownership_controls.log_bucket_ownership_controls]
}

resource "aws_s3_bucket" "bucket" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = var.s3_bucket
  tags = {
    "Managed by" = "Terraform"
  }

  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.bucket[count.index].id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_logging" "bucket" {
  count         = var.create_s3_bucket && var.s3_log_bucket != null ? 1 : 0
  bucket        = aws_s3_bucket.bucket[count.index].id
  target_bucket = aws_s3_bucket.log_bucket[count.index].id
  target_prefix = "log/"
}

resource "aws_s3_bucket_policy" "this" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.bucket[count.index].bucket
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.bucket[count.index].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.bucket[count.index].id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.bucket_ownership_controls]
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_liftecycle" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.bucket[count.index].id

  rule {
    id     = "cloudtrail_logs_retention_policy"
    status = "Enabled"

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
