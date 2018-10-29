output "trail_arn" {
  value = "${aws_cloudtrail.cloudtrail.arn}"
}

output "cloudtrail_s3_bucket" {
  value = "${var.cloudtrail_s3_bucket}"
}