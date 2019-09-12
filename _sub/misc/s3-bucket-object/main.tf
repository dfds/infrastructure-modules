resource "aws_s3_bucket_object" "object" {
  count = "${var.deploy ? 1 :0}"
  bucket = "${var.s3_bucket}"
  key    = "${var.key}"
  source = "${var.filepath}"

  etag = "${filemd5(var.filepath)}"
}