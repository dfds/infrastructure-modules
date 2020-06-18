output "sns_arn" {
  value = aws_sns_topic.cloudwatch_alarms[0].arn
}