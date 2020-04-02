resource "aws_iam_role" "iam_for_lambda" {
  count = var.deploy ? 1 : 0
  name_prefix = var.function_name

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

resource "aws_lambda_function" "cloudwatch_alb_500_to_slack" {
  count = var.deploy ? 1 : 0
  filename      = "${path.module}/lambda_function_payload.zip"
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda[0].arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("${path.module}/lambda_function_payload.zip")

  runtime = "python3.7"

  environment {
    variables = {
      slackChannel = var.slack_channel
      slackHook    = var.slack_hook
    }
  }
}

resource "aws_lambda_permission" "cloudwatch_alb_500_to_slack" {
  count = var.deploy ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudwatch_alb_500_to_slack[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alb_500_errors[0].arn
}
