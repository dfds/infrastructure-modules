resource "aws_s3_bucket_object" "object" {
  bucket = "${var.s3_bucket}"
  key    = "${var.key}"
  source = "${var.filepath}"

  etag = "${filemd5(var.filepath)}"
}