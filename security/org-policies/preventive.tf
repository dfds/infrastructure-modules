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

    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = var.ec2_exempted_accounts
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
  
  statement {
    sid    = "DenyAWSBackupOnSpecificTag"
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
      test     = "StringLike"
      variable = "aws:ResourceTag/dfds.owner"
      values   = [var.resource_owner_tag_value]
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
      test     = "StringLike"
      variable = "aws:ResourceTag/dfds.owner"
      values   = [var.resource_owner_tag_value]
    }
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/OrgRole"]
    }
  }
}