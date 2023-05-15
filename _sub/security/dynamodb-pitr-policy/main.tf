# Allow trigger AWSConfig Remediation for Dynamodb
data "aws_iam_policy_document" "awsconfig_dynamodb_pitr_settings" {
  count = var.deploy ? 1 : 0
  statement {
    sid       = "UpdatePitrSettings"
    effect    = "Allow"
    resources = ["arn:aws:dynamodb:eu-central-1:*:table/*"]

    actions = [
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:UpdateContinuousBackups",
    ]
  }
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.config_bucket[count.index].arn,
      "${aws_s3_bucket.config_bucket[count.index].arn}/*"
    ]
  }
}



data "aws_iam_policy_document" "assume_ssm_role" {
  count = var.deploy ? 1 : 0
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count              = var.deploy ? 1 : 0
  name               = "awsconfig-dynamodb-pitr-remediation"
  assume_role_policy = data.aws_iam_policy_document.assume_ssm_role[count.index].json
}

resource "aws_iam_role_policy" "awsconfig_dynamodb_pitr_settings" {
  count  = var.deploy ? 1 : 0
  name   = "dynamodb-access"
  role   = aws_iam_role.this[count.index].id
  policy = data.aws_iam_policy_document.awsconfig_dynamodb_pitr_settings[count.index].json
}

resource "aws_config_config_rule" "this" {
  count      = var.deploy ? 1 : 0
  name = "dynamodb-pitr"

  source {
    owner             = "AWS"
    source_identifier = "DYNAMODB_PITR_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder.this
  ]
}

resource "aws_config_remediation_configuration" "this" {
  count      = var.deploy ? 1 : 0
  config_rule_name = aws_config_config_rule.this[count.index].name
  resource_type    = "AWS::DynamoDB::Table"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWSConfigRemediation-EnablePITRForDynamoDbTable"
  target_version   = "1"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.this[count.index].arn
  }
  parameter {
    name           = "TableName"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 5
  retry_attempt_seconds      = 600

  execution_controls {
    ssm_controls {
      concurrent_execution_rate_percentage = 10
      error_percentage                     = 5
    }
  }
}



# Enable Recorder in the account

data "aws_iam_policy_document" "assume_recorder_role" {
  count = var.deploy ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "recorder" {
  count              = var.deploy ? 1 : 0
  name               = "aws-config-recorder"
  assume_role_policy = data.aws_iam_policy_document.assume_recorder_role[count.index].json
}

resource "aws_iam_role_policy" "recorder" {
  count  = var.deploy ? 1 : 0
  name   = "aws-config-recorder"
  role   = aws_iam_role.recorder[count.index].id
  policy = data.aws_iam_policy_document.awsconfig_dynamodb_pitr_settings[count.index].json
}

resource "aws_iam_role_policy_attachment" "recorder" {
  count      = var.deploy ? 1 : 0
  role       = aws_iam_role.recorder[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# AWS Config - move to its own module

resource "aws_config_configuration_recorder" "this" {
  count    = var.deploy ? 1 : 0
  name     = "aws-config-recorder"
  role_arn = aws_iam_role.recorder[count.index].arn

  recording_group {
    all_supported = false
    resource_types = [
      "AWS::DynamoDB::Table"
    ]
  }
}


resource "aws_config_configuration_recorder_status" "this" {
  count    = var.deploy ? 1 : 0
  name       = aws_config_configuration_recorder.this[count.index].name
  is_enabled = true
  depends_on = [
    aws_config_delivery_channel.this
  ]
}

data "aws_caller_identity" "current" {
  count    = var.deploy ? 1 : 0
}

# module "config_bucket" {
#   source = "git::https://github.com/dfds/infrastructure-modules.git//aws-modules-s3?ref=v1.3.0"
# }

resource "aws_config_delivery_channel" "this" {
  count          = var.deploy ? 1 : 0
  name           = "aws-config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket[count.index].bucket
}

resource "aws_s3_bucket" "config_bucket" { # TODO: Call a module from our repo
  count          = var.deploy ? 1 : 0
  force_destroy  = true
  bucket = "aws-config-${data.aws_caller_identity.current[count.index].account_id}"
}

# resource "aws_config_configuration_recorder_status" "this" {
#   count      = var.deploy ? 1 : 0
#   name       = aws_config_configuration_recorder.this[count.index].name
#   is_enabled = true
#   depends_on = [aws_config_delivery_channel.this]
# }



#aws configservice start-config-rules-evaluation --config-rule-names dynamodb-pitr