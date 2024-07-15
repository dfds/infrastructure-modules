data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

resource "aws_sqs_queue" "queue" {
  count                      = var.deploy ? 1 : 0
  name_prefix                = var.name
  visibility_timeout_seconds = 330
}

data "aws_iam_policy_document" "sqs_policy" {
  count = var.deploy ? 1 : 0

  statement {
    sid       = "Admin"
    effect    = "Allow"
    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.queue[0].arn]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid       = "SNSSubscription"
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.queue[0].arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        var.sns_topic_arn_cis_controls,
        var.sns_topic_arn_compliance_changes,
        var.sns_topic_arn_guard_duty_findings,
        var.sns_topic_arn_guard_duty_findings_2
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "sqs" {
  count     = var.deploy ? 1 : 0
  queue_url = aws_sqs_queue.queue[0].id

  policy = data.aws_iam_policy_document.sqs_policy[0].json
}

resource "aws_sns_topic_subscription" "cis_controls" {
  count     = var.deploy ? 1 : 0
  topic_arn = var.sns_topic_arn_cis_controls
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue[0].arn
}

resource "aws_sns_topic_subscription" "compliance_changes" {
  count     = var.deploy ? 1 : 0
  topic_arn = var.sns_topic_arn_compliance_changes
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue[0].arn
}

resource "aws_sns_topic_subscription" "guard_duty_findings" {
  count     = var.deploy ? 1 : 0
  topic_arn = var.sns_topic_arn_guard_duty_findings
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue[0].arn
}

resource "aws_sns_topic_subscription" "guard_duty_findings_2" {
  count     = var.deploy ? 1 : 0
  topic_arn = var.sns_topic_arn_guard_duty_findings_2
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue[0].arn
  provider  = aws.workload_2
}


data "aws_iam_policy_document" "trust" {
  count = var.deploy ? 1 : 0
  statement {
    sid     = "AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "key" {
  count                    = var.deploy ? 1 : 0
  description              = "Security SSM SSE"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  is_enabled               = true
  deletion_window_in_days  = 30
  enable_key_rotation      = true
}

resource "aws_ssm_parameter" "slack_token" {
  count       = var.deploy ? 1 : 0
  name        = "/managed/security/slack-token"
  description = "The Slack token for the Security Bot Lambda."
  type        = "SecureString"
  key_id      = aws_kms_key.key[0].key_id
  value       = var.slack_token
}

resource "aws_kms_alias" "alias" {
  count         = var.deploy ? 1 : 0
  name          = "alias/ssm/security"
  target_key_id = aws_kms_key.key[0].key_id
}

data "aws_iam_policy_document" "key_policy" {
  count = var.deploy ? 1 : 0

  statement {
    sid       = "AllowLambdaDecryption"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda[0].arn]
    }
  }

  # This statement is primarily to allow the AWS Config recorder and AWS Recon
  # to be able to record/monitor the configuration of this key.
  statement {
    sid    = "AllowMetadataAccess"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListGrants",
      "kms:ListResourceTags"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "AllowAdminAccess"
    effect = "Allow"
    actions = [
      "kms:Create*",
      "kms:Decrypt",
      "kms:Describe*",
      "kms:Enable*",
      "kms:Encrypt",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_session_context.current.issuer_arn]
    }
  }
}

resource "aws_kms_key_policy" "policy" {
  count  = var.deploy ? 1 : 0
  key_id = aws_kms_key.key[0].key_id
  policy = data.aws_iam_policy_document.key_policy[0].json
}

data "aws_iam_policy_document" "lambda" {
  count = var.deploy ? 1 : 0

  statement {
    sid    = "ConsumeMessages"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [aws_sqs_queue.queue[0].arn]
  }

  statement {
    sid    = "PublishMessages"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
    ]

    resources = [aws_sqs_queue.queue[0].arn]
  }

  statement {
    sid    = "CloudTrailLogs"
    effect = "Allow"
    actions = [
      "logs:FilterLogEvents",
    ]

    resources = [
      var.cloudwatch_logs_group_arn,
      "${var.cloudwatch_logs_group_arn}:log-stream:"
    ]
  }

  statement {
    sid    = "ReadSSMParams"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
    ]

    resources = [aws_ssm_parameter.slack_token[0].arn]
  }

  statement {
    sid    = "DecryptSSMParams"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]

    resources = [aws_kms_key.key[0].arn]
  }

  statement {
    sid    = "ReadIam"
    effect = "Allow"
    actions = [
      "iam:ListUsers",
      "iam:ListAccessKeys",
      "iam:GetAccessKeyLastUsed"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CheckConfigControlComplianceStatus"
    effect = "Allow"
    actions = [
      "config:GetComplianceDetailsByConfigRule",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  count       = var.deploy ? 1 : 0
  name        = "lambda-${aws_sqs_queue.queue[0].name}"
  description = "Attach this policy to the Security Bot Lambda consuming from the ${aws_sqs_queue.queue[0].name} queue"
  policy      = data.aws_iam_policy_document.lambda[0].json
}

resource "aws_iam_role" "lambda" {
  count       = var.deploy ? 1 : 0
  name_prefix = var.name

  assume_role_policy = data.aws_iam_policy_document.trust[0].json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  count      = var.deploy ? 1 : 0
  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.lambda_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "exec" {
  count      = var.deploy ? 1 : 0
  role       = aws_iam_role.lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Source can be found at https://github.com/dfds/security-bot
resource "aws_lambda_function" "bot" {
  count         = var.deploy ? 1 : 0
  s3_bucket     = var.lambda_s3_bucket
  s3_key        = "security-bot/security-bot-${var.lambda_version}.zip"
  function_name = aws_iam_role.lambda[0].name
  role          = aws_iam_role.lambda[0].arn
  handler       = "bootstrap"
  runtime       = "provided.al2"
  timeout       = 300

  logging_config {
    log_format = "JSON"
    log_group = aws_cloudwatch_log_group.lambda_log_group.name
  }

  environment {
    variables = {
      AWS_ACCOUNT_NAME                  = var.account_name
      SLACK_TOKEN                       = aws_ssm_parameter.slack_token[0].name
      SLACK_CHANNEL                     = var.slack_channel
      CLOUD_WATCH_LOGS_GROUP_NAME       = var.cloudwatch_logs_group_name
      SNS_TOPIC_ARN_CIS_CONTROLS        = var.sns_topic_arn_cis_controls
      SNS_TOPIC_ARN_COMPLIANCE_CHANGES  = var.sns_topic_arn_compliance_changes
      SNS_TOPIC_ARN_GUARD_DUTY_FINDINGS = var.sns_topic_arn_guard_duty_findings
      SNS_TOPIC_ARN_GUARD_DUTY_FINDINGS_2 = var.sns_topic_arn_guard_duty_findings_2
      SQS_FOLLOW_UP_QUEUE_URL           = aws_sqs_queue.queue[0].id # `id` provides the URL
    }
  }
    depends_on = [
    aws_cloudwatch_log_group.lambda_log_group,
  ]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  count             = var.deploy ? 1 : 0
  name              = "/aws/lambda/security/${aws_iam_role.lambda[0].name}"
  retention_in_days = 90
}

resource "aws_lambda_event_source_mapping" "sqs" {
  count                              = var.deploy ? 1 : 0
  event_source_arn                   = aws_sqs_queue.queue[0].arn
  enabled                            = true
  function_name                      = aws_lambda_function.bot[0].arn
  batch_size                         = 10
  maximum_batching_window_in_seconds = 5
}
