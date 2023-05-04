output "bucket_name" {
  value = aws_s3_bucket.velero_storage.bucket
}

output "role_arn" {
  value = aws_iam_role.velero_role.arn
}
