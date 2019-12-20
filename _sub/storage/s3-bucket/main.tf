resource "aws_s3_bucket" "bucket" {
  count  = var.deploy
  bucket = var.s3_bucket
  acl    = var.acl

  tags = {
    "Managed by" = "Terraform"
  }

  force_destroy = true
}

