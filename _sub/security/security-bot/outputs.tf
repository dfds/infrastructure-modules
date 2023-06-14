output "sns_arn" {
  value = try(aws_sqs_queue.queue[0].arn, "")
}
