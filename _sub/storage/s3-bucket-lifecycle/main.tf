# tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-s3-specify-public-access-block tfsec:ignore:aws-s3-no-public-buckets tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket" "bucket" {
  bucket        = var.name
  force_destroy = true

  tags = {
    "Managed by" = "Terraform"
  }

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

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = var.acl
}
