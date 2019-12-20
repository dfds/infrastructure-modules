resource "aws_s3_bucket" "bucket" {
  count  = var.deploy ? 1 : 0
  bucket = var.s3_bucket
  acl    = var.acl

  tags = {
    "Managed by" = "Terraform"
  }

  force_destroy = true
}

