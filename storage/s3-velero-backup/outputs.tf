output "bucket_name" {
  value = aws_s3_bucket.velero_storage.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.velero_storage.arn
}
