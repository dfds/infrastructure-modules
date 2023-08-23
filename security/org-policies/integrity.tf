data "aws_iam_policy_document" "integrity" {

  statement {
    sid       = "DenyDeletingVPCFlowLogs"
    effect    = "Deny"
    actions   = ["ec2:DeleteFlowLogs"]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
        "arn:aws:iam::*:role/EKSAdmin",
      ]
      variable = "aws:PrincipalArn"
    }
  }

  statement {
    sid    = "DenyDeletingCloudWatchLogs"
    effect = "Deny"
    actions = [
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
    ]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/EKSAdmin",
        "arn:aws:iam::*:role/OrgRole",
      ]
      variable = "aws:PrincipalArn"
    }
  }

  statement {
    sid    = "DenyDisablingCloudTrail"
    effect = "Deny"
    actions = [
      "cloudtrail:StopLogging",
      "cloudtrail:DeleteTrail",
      "cloudtrail:UpdateTrail",
    ]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
      ]
      variable = "aws:PrincipalArn"
    }
  }

  statement {
    sid       = "DenyDisablingAccessAnalyzer"
    effect    = "Deny"
    actions   = ["access-analyzer:DeleteAnalyzer"]
    resources = ["*"]
  }

  statement {
    sid    = "DenyDisablingEditingAWSConfig"
    effect = "Deny"
    actions = [
      "config:DeleteConfigRule",
      "config:DeleteConfigurationRecorder",
      "config:DeleteDeliveryChannel",
      "config:StopConfigurationRecorder",
      "config:PutConfigRule",
    ]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
      ]
      variable = "aws:PrincipalArn"
    }
  }
}