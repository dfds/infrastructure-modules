# tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-s3-specify-public-access-block tfsec:ignore:aws-s3-no-public-buckets tfsec:ignore:aws-s3-encryption-customer-key tfsec:ignore:aws-s3-block-public-acls tfsec:ignore:aws-s3-block-public-policy tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-ignore-public-acls
resource "aws_s3_bucket" "bucket" {
  count         = var.deploy ? 1 : 0
  bucket        = var.s3_bucket
  force_destroy = true

  tags = merge(
    var.additional_tags,
    {
      "Managed by" = "Terraform"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  count  = var.deploy && var.acl == "public-read" ? 1 : 0
  bucket = aws_s3_bucket.bucket[count.index].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  count  = var.deploy ? 1 : 0
  bucket = aws_s3_bucket.bucket[count.index].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# tfsec:ignore:aws-s3-no-public-access-with-acl
resource "aws_s3_bucket_acl" "bucket_acl" {
  count  = var.deploy ? 1 : 0
  bucket = aws_s3_bucket.bucket[count.index].id
  acl    = var.acl

  depends_on = [
    aws_s3_bucket_public_access_block.bucket,
    aws_s3_bucket_ownership_controls.bucket,
  ]
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
