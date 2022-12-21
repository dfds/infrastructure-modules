# tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-s3-specify-public-access-block tfsec:ignore:aws-s3-no-public-buckets tfsec:ignore:aws-s3-encryption-customer-key tfsec:ignore:aws-s3-block-public-acls tfsec:ignore:aws-s3-block-public-policy tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "bucket" {
  count         = var.deploy ? 1 : 0
  bucket        = var.s3_bucket
  force_destroy = true

  tags = merge(
    var.additional_tags,
    var.is_sandbox ? local.sandbox_tags : {},
    {
      "Managed by" = "Terraform"
    }
  )
}

locals {
  sandbox_tags = {
    "is_sandbox" = "true"
  }
}

# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  count  = var.deploy && var.enable_server_side_encryption ? 1 : 0
  bucket = aws_s3_bucket.bucket[count.index].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count  = var.deploy ? 1 : 0
  bucket = aws_s3_bucket.bucket[count.index].id
  acl    = var.acl
}
