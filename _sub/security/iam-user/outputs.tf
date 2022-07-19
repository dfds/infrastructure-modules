output "arn" {
  value = aws_iam_user.user.arn
}

output "access_key" {
  value = var.create_aws_iam_access_key ? aws_iam_access_key.key.id : ""
}

output "secret_key" {
  value     = var.create_aws_iam_access_key ? aws_iam_access_key.key.secret : "" 
  sensitive = true
}

