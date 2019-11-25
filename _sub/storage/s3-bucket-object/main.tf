resource "aws_s3_bucket_object" "object" {
  count   = "${var.deploy}"
  bucket  = "${var.bucket}"
  key     = "${var.key}"
  content = "${var.content}"
  acl     = "${var.acl}"
}
