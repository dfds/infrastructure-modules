output "s3_object_key" {
  value = "${aws_s3_bucket_object.object.id}" # see here: https://www.terraform.io/docs/providers/aws/r/s3_bucket_object.html#id
}
