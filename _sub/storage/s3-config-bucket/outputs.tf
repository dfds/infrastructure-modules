output "bucket_name" {
  value = try(aws_s3_bucket.bucket[0].bucket, null)
}

output "bucket_arn" {
  value = try(aws_s3_bucket.bucket[0].arn, null)
}

