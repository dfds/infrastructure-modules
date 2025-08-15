output "arn" {
  description = "The ARN of the lambda function"
  value       = aws_lambda_function.this.arn
}

output "name" {
  value = var.name
}

output "role_name" {
  description = "The name of the lambda function role"
  value       = aws_iam_role.this.name
}
