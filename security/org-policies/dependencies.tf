data "aws_iam_policy_document" "preventive" {

  statement {
    sid       = "DenyExpensiveEC2"
    effect    = "Deny"
    actions   = ["ec2:RunInstances"]
    resources = ["arn:aws:ec2:*:*:instance/*"]

    condition {
      test     = "StringLike"
      variable = "ec2:InstanceType"
      values = [
        "i*",
        "p*",
        "x*",
        "*.1*",
        "*.8*",
        "*.24*",
        "*.metal",
      ]
    }
  }

  statement {
    sid    = "DenyVPNCreation"
    effect = "Deny"
    actions = [
      "ec2:AttachVpnGateway",
      "ec2:CreateVpnConnection",
      "ec2:CreateVpnConnectionRoute",
      "ec2:CreateVpnGateway",
      "ec2:DeleteVpnConnection",
      "ec2:DeleteVpnConnectionRoute",
      "ec2:DeleteVpnGateway",
      "ec2:DetachVpnGateway",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyDisablingGuardDuty"
    effect = "Deny"
    actions = [
      "guardduty:AcceptInvitation",
      "guardduty:ArchiveFindings",
      "guardduty:CreateDetector",
      "guardduty:CreateFilter",
      "guardduty:CreateIPSet",
      "guardduty:CreateMembers",
      "guardduty:CreatePublishingDestination",
      "guardduty:CreateSampleFindings",
      "guardduty:CreateThreatIntelSet",
      "guardduty:DeclineInvitations",
      "guardduty:DeleteDetector",
      "guardduty:DeleteFilter",
      "guardduty:DeleteInvitations",
      "guardduty:DeleteIPSet",
      "guardduty:DeleteMembers",
      "guardduty:DeletePublishingDestination",
      "guardduty:DeleteThreatIntelSet",
      "guardduty:DisassociateFromMasterAccount",
      "guardduty:DisassociateMembers",
      "guardduty:InviteMembers",
      "guardduty:StartMonitoringMembers",
      "guardduty:StopMonitoringMembers",
      "guardduty:TagResource",
      "guardduty:UnarchiveFindings",
      "guardduty:UntagResource",
      "guardduty:UpdateDetector",
      "guardduty:UpdateFilter",
      "guardduty:UpdateFindingsFeedback",
      "guardduty:UpdateIPSet",
      "guardduty:UpdatePublishingDestination",
      "guardduty:UpdateThreatIntelSet",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "DenyLeavingOfOrganisation"
    effect    = "Deny"
    actions   = ["organizations:LeaveOrganization"]
    resources = ["*"]
  }

  statement {
    sid    = "DenyDisablingSecurityHub"
    effect = "Deny"
    actions = [
      "securityhub:DeleteInvitations",
      "securityhub:DisableSecurityHub",
      "securityhub:DisassociateFromMasterAccount",
      "securityhub:DeleteMembers",
      "securityhub:DisassociateMembers",
      "securityhub:UpdateStandardsControl",
      "securityhub:BatchUpdateStandardsControlAssociations",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyDisablingMacie"
    effect = "Deny"
    actions = [
      "macie2:DisassociateFromMasterAccount",
      "macie2:DisableOrganizationAdminAccount",
      "macie2:DisableMacie",
      "macie2:DeleteMember",
    ]
    resources = ["*"]
  }
}

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

  statement {
    sid    = "DenyAWSBackuponSpecificTag"
    effect = "Deny"
    actions = [
      "backup:CreateBackupPlan",
      "backup:CreateBackupSelection",
      "backup:CreateBackupVault",
      "backup:CreateFramework",
      "backup:CreateLegalHold",
      "backup:CreateReportPlan",
      "backup:DeleteBackupPlan",
      "backup:DeleteBackupSelection",
      "backup:DeleteBackupVault",
      "backup:DeleteBackupVaultLockConfiguration",
      "backup:DeleteBackupVaultNotifications",
      "backup:DeleteFramework",
      "backup:DeleteRecoveryPoint",
      "backup:DeleteReportPlan",
      "backup:DeleteBackupVaultAccessPolicy",
      "backup:DisassociateRecoveryPoint",
      "backup:DisassociateRecoveryPointFromParent",
      "backup:PutBackupVaultAccessPolicy",
      "backup:UpdateBackupPlan",
      "backup:UpdateFramework",
      "backup:UpdateRecoveryPointLifecycle",
      "backup:UpdateReportPlan",
    ]
    resources = ["*"]

    condition {
      test = "StringLike"
      variable = "aws:ResourceTag/dfds.owner"
      values = [var.resource_owner_tag_value]
    }
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/OrgRole"]
    }
  }

  statement {
    sid    = "DenyTagOperations"
    effect = "Deny"
    actions = [
      "backup:UntagResource",
    ]
    resources = ["*"]

    condition {
      test = "StringLike"
      variable = "aws:ResourceTag/dfds.owner" 
      values = [var.resource_owner_tag_value]
      }
      condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/OrgRole"]
    }
  }
}

data "aws_iam_policy_document" "reservation" {

  statement {
    sid    = "ECSDenyAccessToRI"
    effect = "Deny"
    actions = [
      "ec2:PurchaseReservedInstancesOffering",
      "ec2:AcceptReservedInstancesExchangeQuote",
      "ec2:CancelCapacityReservation",
      "ec2:CancelReservedInstancesListing",
      "ec2:CreateCapacityReservation",
      "ec2:CreateReservedInstancesListing",
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
    sid       = "RDSDenyAccessToRI"
    effect    = "Deny"
    actions   = ["rds:PurchaseReservedDBInstancesOffering"]
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
    sid       = "ElastiCacheDenyAccessToRI"
    effect    = "Deny"
    actions   = ["elasticache:PurchaseReservedCacheNodesOffering"]
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
    sid    = "ESDenyAccessToRI"
    effect = "Deny"
    actions = [
      "es:PurchaseReservedElasticsearchInstanceOffering",
      "es:PurchaseReservedInstanceOffering",
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
    sid       = "RedShiftDenyAccessToRI"
    effect    = "Deny"
    actions   = ["redshift:PurchaseReservedNodeOffering"]
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
    sid       = "DynamoDbDenyAccessToRI"
    effect    = "Deny"
    actions   = ["dynamodb:PurchaseReservedCapacityOfferings"]
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
}
