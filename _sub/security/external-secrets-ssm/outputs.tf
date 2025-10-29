output "ssm_iam_role_arn" {
  description = "The ARN of the IAM role for External Secrets Operator to access SSM parameters"
  value       = aws_iam_role.this.arn
}