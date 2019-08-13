output "bucket_domain_name" {
  value = aws_s3_bucket.bucket.bucket_regional_domain_name
}

output "bucket_name" {
  value = "${element(concat(aws_s3_bucket.bucket.*.id, list("")), 0)}"
}