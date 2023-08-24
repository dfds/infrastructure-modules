data "aws_iam_policy_document" "restrictive" {

  statement {
    sid    = "DenyIAMUpdatesManagedUsers"
    effect = "Deny"
    actions = [
      "iam:AttachUserPolicy",
      "iam:DeleteUserPolicy",
      "iam:DetachUserPolicy",
      "iam:PutUserPolicy",
    ]
    resources = [
      "arn:aws:iam::*:user/Deploy",
      "arn:aws:iam::*:user/managed/*",
    ]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
      ]
      variable = "aws:PrincipalArn"
    }
  }

  statement {
    sid    = "DenyMFA"
    effect = "Deny"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeactivateMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
    ]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
        "arn:aws:iam::*:root",
      ]
      variable = "aws:PrincipalArn"
    }
  }

  statement {
    sid    = "DenyIAM"
    effect = "Deny"
    actions = [
      "iam:AddUserToGroup",
      "iam:AttachGroupPolicy",
      "iam:ChangePassword",
      "iam:CreateAccountAlias",
      "iam:CreateGroup",
      "iam:CreateLoginProfile",
      "iam:CreateSAMLProvider",
      "iam:CreateUser",
      "iam:DeleteAccountAlias",
      "iam:DeleteAccountPasswordPolicy",
      "iam:DeleteGroup",
      "iam:DeleteGroupPolicy",
      "iam:DeleteSAMLProvider",
      "iam:DetachGroupPolicy",
      "iam:PutGroupPolicy",
      "iam:PutUserPermissionsBoundary",
      "iam:RemoveUserFromGroup",
      "iam:UpdateAccountPasswordPolicy",
      "iam:UpdateGroup",
      "iam:UpdateLoginProfile",
      "iam:UpdateSAMLProvider",
      "iam:UpdateUser",
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
    sid    = "DenyIAMDeploy"
    effect = "Deny"
    actions = [
      "iam:DeleteUser",
      "iam:DeleteUserPermissionsBoundary",
      "iam:DeleteUserPolicy",
      "iam:DeleteLoginProfile",
    ]
    resources = [
      "arn:aws:iam::*:user/Deploy",
      "arn:aws:iam::*:user/managed/*",
    ]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
      ]
      variable = "aws:PrincipalArn"
    }
  }

  statement {
    sid    = "DenyOrgRoleModification"
    effect = "Deny"
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:CreateServiceLinkedRole",
      "iam:DeleteRole",
      "iam:DeleteRole*",
      "iam:DeleteServiceLinkedRole",
      "iam:DetachRolePolicy",
      "iam:PutRole*",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
    ]
    resources = [
      "arn:aws:iam::*:role/OrgRole",
    ]
  }

  statement {
    sid    = "CoreRegionOnly"
    effect = "Deny"
    not_actions = [
      "access-analyzer:*",
      "account:Get*",
      "account:List*",
      "account:PutAlternateContact",
      "account:DeleteAlternateContact",
      "acm:*",
      "aws-marketplace:*",
      "billing:Get*",
      "billing:List*",
      "budgets:*",
      "ce:CreateReport",
      "ce:Describe*",
      "ce:Get*",
      "ce:List*",
      "cloudfront:*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DescribeAlarm*",
      "cur:Get*",
      "dynamoDB:Describe*",
      "ec2:Describe*",
      "ecr:BatchGetImage",
      "ecr:Describe*",
      "ecr:Get*",
      "ecr:List*",
      "ecr-public:*",
      "freetier:Get*",
      "globalaccelerator:*",
      "health:Describe*",
      "iam:*",
      "importexport:*",
      "invoicing:Get*",
      "invoicing:List*",
      "kms:*",
      "lambda:*",
      "organizations:*",
      "payments:Get*",
      "payments:List*",
      "route53:*",
      "route53domains:ListDomains",
      "rds:Describe*",
      "s3:GetBucketLocation",
      "s3:GetStorageLens*",
      "s3:List*",
      "shield:*",
      "sts:*",
      "ssm:DescribeParameters",
      "sso:DescribeRegisteredRegions",
      "support:*",
      "tax:Get*",
      "tax:List*",
      "elasticloadbalancing:*",
      "apigateway:*",
      "appsync:*",
      "waf-regional:*",
      "wafv2:*",
      "waf:*",
      "deepracer:*",
      "logs:Describe*",
      "logs:GetLog*",
      "logs:ListTags*",
      "logs:DescribeSubscriptionFilters",
      "notifications:Get*",
      "notifications:List*",
      "sns:*",
      "resource-explorer-2:*",
    ]
    resources = ["*"]
    condition {
      test = "StringNotLike"
      values = [
        "eu-central-1",
        "eu-west-1",
      ]
      variable = "aws:RequestedRegion"
    }
  }

  statement {
    sid    = "DenyResourceExplorer"
    effect = "Deny"
    actions = [
      "resource-explorer-2:Create*",
      "resource-explorer-2:Delete*",
      "resource-explorer-2:Update*",
      "resource-explorer-2:Tag*",
      "resource-explorer-2:Untag*",
      "resource-explorer-2:Associate*",
      "resource-explorer-2:Disassociate*",
    ]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
        "arn:aws:iam::*:user/deploy-prime-core",
      ]
      variable = "aws:PrincipalArn"
    }
  }

  statement {
    sid    = "DenyCostManagement"
    effect = "Deny"
    actions = [
      "savingsplans:*",
    ]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_CloudAdmin_*",
        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_Billing_*",
      ]
      variable = "aws:PrincipalArn"
    }
  }

  statement {
    sid    = "DenyDisallowedServices"
    effect = "Deny"
    actions = [
      "codestar:*",
      "codecommit:*",
      "codeartifact:*",
      "codebuild:*",
      "codedeploy:*",
      "codepipeline:*",
      "codewhisperer:*",
      "codecatalyst:*",
      "gamelift:*",
      "gamesparks:*",
      "groundstation:*",
      "cloudhsm:*",
      "cloud9:*",
      "managedblockchain:*",
    ]
    resources = ["*"]

    condition {
      test = "StringNotLike"
      values = [
        "arn:aws:iam::*:role/OrgRole",
        "arn:aws:iam::*:role/aws-config-recorder*",
        "arn:aws:iam::*:role/inventory",
      ]
      variable = "aws:PrincipalArn"
    }
  }
}