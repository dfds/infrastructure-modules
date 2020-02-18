resource "aws_s3_bucket_object" "object" {
  count   = var.deploy ? 1 : 0
  bucket  = var.bucket
  key     = var.key
  content = var.content
  acl     = var.acl
}