# data "aws_caller_identity" "current" {
#   provider = "aws.core"
# }

data "aws_iam_policy_document" "assume_role_policy_self" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${module.org_account.id}:root"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy_selfservice" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.shared_account_id}:role/aad-aws-sync"]
    }
  }
}

// Gives access to role through the individual Capability account
data "aws_iam_policy_document" "shared_role_cap_acc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${module.org_account.id}:root"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy_master_account" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.master_account_id}:user/CerteroEndpointUser"]
    }
  }
}

# --------------------------------------------------
# IAM role for Grafana Cloud Cloudwatch integration
# --------------------------------------------------
locals {
  grafana_cloud_iam_role_name                  = "grafana-cloud-cloudwatch-integration"
  grafana_cloud_cloudwatch_integration_enabled = var.grafana_cloud_iam_role != null ? true : false
}

data "aws_iam_policy_document" "grafana_cloud_cloudwatch_permissions" {
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

data "aws_iam_policy_document" "grafana_cloud_cloudwatch_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = var.grafana_cloud_iam_role.external_ids
    }

    principals {
      type        = "AWS"
      identifiers = [var.grafana_cloud_iam_role.arn]
    }
  }
}
