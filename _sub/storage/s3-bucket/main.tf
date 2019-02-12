resource "aws_s3_bucket" "bucket" {
  count  = "${var.deploy}"
  bucket = "${var.s3_bucket}"

  tags = {
    "Managed by" = "Terraform"
  }

  force_destroy = true
}
