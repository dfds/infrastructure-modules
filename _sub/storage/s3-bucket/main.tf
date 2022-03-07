# tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "bucket" {
  count         = var.deploy ? 1 : 0
  bucket        = var.s3_bucket
  acl           = var.acl
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = {
    "Managed by" = "Terraform"
  }
}
