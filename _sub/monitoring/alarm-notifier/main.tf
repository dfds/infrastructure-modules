#tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "cloudwatch_alarms" {
  count = var.deploy ? 1 : 0
  name  = var.name
}

resource "aws_sns_topic_subscription" "cloudwatch_alarms" {
  count     = var.deploy ? 1 : 0
  topic_arn = aws_sns_topic.cloudwatch_alarms[0].arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_alarm_notifier[0].arn
}

resource "aws_iam_role" "iam_for_lambda" {
  count       = var.deploy ? 1 : 0
  name_prefix = var.name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "slack_alarm_notifier" {
  count         = var.deploy ? 1 : 0
  filename      = "${path.module}/lambda/slack-alarm-notifier.zip"
  function_name = aws_iam_role.iam_for_lambda[0].name
  role          = aws_iam_role.iam_for_lambda[0].arn
  handler       = "main"
  runtime       = "go1.x"

  source_code_hash = filebase64sha256("${path.module}/lambda/slack-alarm-notifier.zip")

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }
}

resource "aws_lambda_permission" "cloudwatch_alarms_slack_notifier_trigger" {
  count         = var.deploy ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_alarm_notifier[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.cloudwatch_alarms[0].arn
}
