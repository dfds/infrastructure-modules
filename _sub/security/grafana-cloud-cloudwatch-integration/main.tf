# --------------------------------------------------
# IAM role for Grafana Cloud Cloudwatch integration
# --------------------------------------------------

locals {
  role_name = "grafana-cloud-cloudwatch-integration"
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    sid    = "CloudWatchReadOnlyAccessPermissions"
    actions = [
      "application-autoscaling:DescribeScalingPolicies",
      "autoscaling:Describe*",
      "cloudwatch:BatchGet*",
      "cloudwatch:Describe*",
      "cloudwatch:GenerateQuery",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "logs:Get*",
      "logs:List*",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:Describe*",
      "logs:TestMetricFilter",
      "logs:FilterLogEvents",
      "logs:StartLiveTail",
      "logs:StopLiveTail",
      "oam:ListSinks",
      "sns:Get*",
      "sns:List*",
      "rum:BatchGet*",
      "rum:Get*",
      "rum:List*",
      "synthetics:Describe*",
      "synthetics:Get*",
      "synthetics:List*",
      "xray:BatchGet*",
      "xray:Get*"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    sid    = "OAMReadPermissions"
    actions = [
      "oam:ListAttachedLinks"
    ]

    resources = ["arn:aws:oam:*:*:sink/*"]
  }
}

data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = var.iam_role.stack_ids
    }

    principals {
      type        = "AWS"
      identifiers = [var.iam_role.arn]
    }
  }
}

module "iam_role" {
  source               = "../iam-role"
  role_name            = local.role_name
  role_description     = "Role for Grafana Cloud to read Cloudwatch data"
  role_policy_name     = local.role_name
  role_policy_document = data.aws_iam_policy_document.policy.json
  assume_role_policy   = data.aws_iam_policy_document.trust.json
}
