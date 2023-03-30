# --------------------------------------------------
# Service Control (Organization) Policies
# --------------------------------------------------

locals {
  preventive_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyExpensiveEC2",
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:instance/*"
      ],
      "Condition": {
        "StringLike": {
          "ec2:InstanceType": [
            "i*",
            "p*",
            "x*",
            "*.1*",
            "*.8*",
            "*.24*",
            "*.metal"
          ]
        }
      }
    },
    {
      "Sid": "DenyVPNCreation",
      "Effect": "Deny",
      "Action": [
        "ec2:AttachVpnGateway",
        "ec2:CreateVpnConnection",
        "ec2:CreateVpnConnectionRoute",
        "ec2:CreateVpnGateway",
        "ec2:DeleteVpnConnection",
        "ec2:DeleteVpnConnectionRoute",
        "ec2:DeleteVpnGateway",
        "ec2:DetachVpnGateway"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "DenyDisablingGuardDuty",
      "Effect": "Deny",
      "Action": [
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
        "guardduty:UpdateThreatIntelSet"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyLeavingOfOrganisation",
      "Effect": "Deny",
      "Action": "organizations:LeaveOrganization",
      "Resource": "*"
    },
    {
      "Sid": "DenyDisablingSecurityHub",
      "Action": [
        "securityhub:DeleteInvitations",
        "securityhub:DisableSecurityHub",
        "securityhub:DisassociateFromMasterAccount",
        "securityhub:DeleteMembers",
        "securityhub:DisassociateMembers",
        "securityhub:UpdateStandardsControl"
      ],
      "Resource": "*",
      "Effect": "Deny"
    },
    {
      "Sid": "DenyDisablingMacie",
      "Action": [
        "macie2:DisassociateFromMasterAccount",
        "macie2:DisableOrganizationAdminAccount",
        "macie2:DisableMacie",
        "macie2:DeleteMember"
      ],
      "Resource": "*",
      "Effect": "Deny"
    }
  ]
}
POLICY


  integrity_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyDeletingVPCFlowLogs",
      "Effect": "Deny",
      "Action": [
        "ec2:DeleteFlowLogs",
        "logs:DeleteLogGroup",
        "logs:DeleteLogStream"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyDisablingCloudTrail",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail"
      ],
      "Resource": "*",
      "Effect": "Deny"
    },
    {
      "Sid": "DenyDisablingAccessAnalyzer",
      "Action": [
        "access-analyzer:DeleteAnalyzer"
      ],
      "Resource": "*",
      "Effect": "Deny"
    },
    {
      "Sid": "DenyDisablingEditingAWSConfig",
      "Action": [
        "config:DeleteConfigRule",
        "config:DeleteConfigurationRecorder",
        "config:DeleteDeliveryChannel",
        "config:StopConfigurationRecorder"
      ],
      "Resource": "*",
      "Effect": "Deny"
    }
  ]
}
POLICY


  restrictive_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyIAMUpdatesManagedUsers",
      "Effect": "Deny",
      "Action": [
        "iam:AttachUserPolicy",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:PutUserPolicy",
        "iam:TagUser",
        "iam:UntagUser"
      ],
      "Resource": [
        "arn:aws:iam::*:user/Deploy",
        "arn:aws:iam::*:user/managed/*"
      ],
      "Condition": {
        "StringNotLike": {
          "aws:PrincipalArn": [
            "arn:aws:iam::*:role/OrgRole"
          ]
        }
      }
    },
    {
      "Sid": "DenyMFA",
      "Effect": "Deny",
      "Action": [
        "iam:CreateVirtualMFADevice",
        "iam:DeactivateMFADevice",
        "iam:DeleteVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:ResyncMFADevice"
      ],
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringNotLike": {
          "aws:PrincipalArn": [
            "arn:aws:iam::*:role/OrgRole",
            "arn:aws:iam::*:root"
          ]
        }
      }
    },
    {
      "Sid": "DenyIAM",
      "Effect": "Deny",
      "Action": [
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
        "iam:UpdateUser"
      ],
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringNotLike": {
          "aws:PrincipalArn": [
            "arn:aws:iam::*:role/OrgRole"
          ]
        }
      }
    },
    {
      "Sid": "DenyIAMDeploy",
      "Effect": "Deny",
      "Action": [
        "iam:DeleteUser",
        "iam:DeleteUserPermissionsBoundary",
        "iam:DeleteUserPolicy",
        "iam:DeleteLoginProfile"
      ],
      "Resource": [
        "arn:aws:iam::*:user/Deploy",
        "arn:aws:iam::*:user/managed/*"
      ],
      "Condition": {
        "StringNotLike": {
          "aws:PrincipalArn": [
            "arn:aws:iam::*:role/OrgRole"
          ]
        }
      }
    },
    {
      "Sid": "DenyOrgRoleModification",
      "Effect": "Deny",
      "Action": [
        "iam:*"
      ],
      "Resource": [
        "arn:aws:iam::*:role/OrgRole"
      ]
    },
    {
      "Sid": "DenyAllOutsideEU",
      "Effect": "Deny",
      "NotAction": [
        "access-analyzer:ValidatePolicy",
        "acm:*",
        "aws-marketplace:*",
        "aws-portal:*",
        "budgets:*",
        "ce:Describe*",
        "ce:Get*",
        "ce:List*",
        "cloudfront:*",
        "cloudwatch:Get*",
        "cloudwatch:List*",
        "dynamoDB:DescribeTable",
        "ecr:BatchGetImage",
        "ecr:Describe*",
        "ecr:Get*",
        "ecr:List*",
        "ecr-public:*",
        "globalaccelerator:*",
        "iam:*",
        "importexport:*",
        "kms:*",
        "lambda:*",
        "organizations:*",
        "route53:*",
        "s3:List*",
        "shield:*",
        "sts:*",
        "support:*",
        "elasticloadbalancing:*",
        "apigateway:*",
        "appsync:*",
        "waf-regional:*",
        "wafv2:*",
        "waf:*",
        "deepracer:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotLike": {
          "aws:RequestedRegion": [
            "eu-*"
          ]
        }
      }
    },
    {
            "Sid": "DenyCostManagement",
            "Effect": "Deny",
            "Action": [
                "ce:*",
                "savingsplans:*"
            ],
            "Resource": [
                "*"
            ],
            "Condition": {
                "StringNotLike": {
                    "aws:PrincipalArn": [
                        "arn:aws:iam::*:role/OrgRole",
                        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_CloudAdmin_*",
                        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_Billing_*"
                    ]
                }
            }
        },
        {
            "Sid": "DenyBillingLegacyRemoveAfterJuly2023",
            "Effect": "Deny",
            "Action": [
                "aws-portal:ViewBilling",
                "aws-portal:ViewPaymentMethods",
                "aws-portal:ViewUsage",
                "aws-portal:ModifyAccount",
                "aws-portal:ModifyBilling",
                "aws-portal:ModifyPaymentMethods"
            ],
            "Resource": [
                "*"
            ],
            "Condition": {
                "StringNotLike": {
                    "aws:PrincipalArn": [
                        "arn:aws:iam::*:role/OrgRole",
                        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_CloudAdmin_*",
                        "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_Billing_*"
                    ]
                }
            }
        }
  ]
}
POLICY

}
