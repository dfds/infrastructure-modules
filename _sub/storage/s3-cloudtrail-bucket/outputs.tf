output "bucket_name" {
  value = "${element(concat(aws_s3_bucket.bucket.*.bucket, list("")), 0)}"
}
