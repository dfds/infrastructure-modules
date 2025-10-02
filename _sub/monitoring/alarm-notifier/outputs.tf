output "sns_arn" {
  value = try(aws_sns_topic.cloudwatch_alarms.arn, "")
}
