output "trail_arn" {
  value = "${aws_cloudtrail.cloudtrail.arn}"
}

output "s3_bucket_name" {
  value = "${var.s3_bucket_name}"
}