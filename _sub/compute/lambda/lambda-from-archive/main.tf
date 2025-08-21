resource "aws_lambda_function" "this" {
  filename      = data.archive_file.this.output_path
  function_name = var.name
  role          = aws_iam_role.this.arn
  handler       = var.function_handler

  source_code_hash = data.archive_file.this.output_base64sha256

  runtime = var.function_runtime

  environment {
    variables = var.function_environment_variables
  }
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    effect = "Allow"

    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]

    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/${var.name}:*"
    ]
  }

  statement {
    effect = "Allow"

    actions = ["logs:CreateLogGroup"]

    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/${var.name}:*"
    ]
  }
}

resource "aws_iam_role_policy" "cloudwatch_logs" {
  name   = "cw-log-access"
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.cloudwatch_logs.json
}

resource "aws_iam_role" "this" {
  name                  = var.name
  force_detach_policies = true

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}
