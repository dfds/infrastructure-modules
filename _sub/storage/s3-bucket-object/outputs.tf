output "id" {
  value = element(concat(aws_s3_bucket_object.object.*.id, [""]), 0)
}

