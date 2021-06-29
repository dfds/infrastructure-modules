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
}
