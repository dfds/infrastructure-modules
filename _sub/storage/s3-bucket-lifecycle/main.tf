# tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "bucket" {
  bucket = var.name
  acl    = var.acl

  tags = {
    "Managed by" = "Terraform"
  }

  force_destroy = true

  lifecycle_rule {
    enabled                                = true
    id                                     = "retention_policy"
    abort_incomplete_multipart_upload_days = var.retention_days

    expiration {
      days = var.retention_days
    }

    noncurrent_version_expiration {
      days = var.retention_days
    }
  }

  policy = var.policy
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
