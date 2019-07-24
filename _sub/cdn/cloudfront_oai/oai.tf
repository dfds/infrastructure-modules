resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.comment}"
}