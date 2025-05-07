output "name" {
  value = aws_s3_bucket.bucket.id
}

output "arn" {
  value = aws_s3_bucket.bucket.arn
}

output "replication_role_arn" {
  value = try(element([
    for role in aws_iam_role.replication_role : role.arn
    if role != null
  ], 0), "")
}
