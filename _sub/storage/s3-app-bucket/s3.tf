resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket
  acl    = var.bucket_canned_acl

  tags = {
    "Managed by" = "Terraform"
  }

  versioning {
    enabled = var.enable_versioning
  }

  force_destroy = var.enable_destroy
}
