# Allow trigger AWSConfig Remediation for Dynamodb
data "aws_iam_policy_document" "awsconfig_dynamodb_pitr_settings" {
  count = var.deploy ? 1 : 0
  statement {
    sid       = "UpdatePitrSettings"
    effect    = "Allow"
    resources = ["arn:aws:dynamodb:eu-west-1:*:table/*"]

    actions = [
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:UpdateContinuousBackups",
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

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.deploy ? 1 : 0
  role       = aws_iam_role.this[count.index].name
  policy_arn = data.aws_iam_policy_document.awsconfig_dynamodb_pitr_settings[count.index].json
}

resource "aws_config_config_rule" "this" {
  count      = var.deploy ? 1 : 0
  name = "dynamodb-pitr"

  source {
    owner             = "AWS"
    source_identifier = "DYNAMODB_PITR_ENABLED"
  }
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
      concurrent_execution_rate_percentage = 2
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

# AWS Config

resource "aws_config_configuration_recorder" "this" {
  count    = var.deploy ? 1 : 0
  name     = "aws-config-recorder"
  role_arn = aws_iam_role.recorder[count.index].arn
}