resource "aws_sns_topic" "alb_500_errors" {
  count = var.deploy ? 1 : 0
  name = var.sns_name
}

resource "aws_sns_topic_subscription" "lambda_sns_to_slack" {
  count = var.deploy ? 1 : 0
  topic_arn = aws_sns_topic.alb_500_errors[0].arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.cloudwatch_alb_500_to_slack[0].arn
}