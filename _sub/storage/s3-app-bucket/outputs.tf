output "bucket_domain_name" {
  value = aws_s3_bucket.bucket.bucket_regional_domain_name
}