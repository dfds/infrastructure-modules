resource "aws_s3_bucket" "bucket" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = var.s3_bucket
  tags = {
    "Managed by" = "Terraform"
  }

  force_destroy = true
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
