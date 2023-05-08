output "cloudwatch_logs_group_name" {
  value = try(aws_cloudwatch_log_group.log_group[0].name, null)
}

output "cloudwatch_logs_group_arn" {
  value = try(aws_cloudwatch_log_group.log_group[0].arn, null)
}
