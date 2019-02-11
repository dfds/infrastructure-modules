resource "aws_s3_bucket" "bucket" {
  bucket = "${var.s3_bucket}"
  tags = {
      "Managed by" = "Terraform"
  }

  force_destroy = true
}