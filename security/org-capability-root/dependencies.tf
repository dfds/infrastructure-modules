data "aws_organizations_organization" "org" {
}

locals {
  denynoneuregions_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyAllOutsideEU",
            "Effect": "Deny",
            "NotAction": [
                "acm:*",
                "aws-marketplace:*",
                "aws-portal:View*",
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
		"waf-regional:*",
		"wafv2:*",
                "waf:*"
            ],
            "Resource": "*",
            "Condition": {
                "StringNotLike": {
                    "aws:RequestedRegion": [
                        "eu-*"
                    ]
                }
            }
        }
    ]
}
POLICY


  denyiam_policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
        {
            "Sid": "DenyIAMUpdatesManagedUsers",
            "Effect": "Deny",
            "Action": [
                "iam:AttachUserPolicy",
                "iam:CreateAccessKey",
                "iam:DeleteAccessKey",
                "iam:DeleteUserPolicy",
                "iam:DetachUserPolicy",
                "iam:PutUserPolicy",
                "iam:TagUser",
                "iam:UntagUser",
                "iam:UpdateAccessKey"
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
        },		{
			"Sid": "DenyIAM",
			"Effect": "Deny",
			"Action": [
				"iam:AddClientIDToOpenIDConnectProvider",
				"iam:AddUserToGroup",
				"iam:AttachGroupPolicy",
				"iam:ChangePassword",
				"iam:CreateAccountAlias",
				"iam:CreateGroup",
				"iam:CreateLoginProfile",
				"iam:CreateOpenIDConnectProvider",
				"iam:CreateSAMLProvider",
				"iam:CreateUser",
				"iam:CreateVirtualMFADevice",
				"iam:DeactivateMFADevice",
				"iam:DeleteAccountAlias",
				"iam:DeleteAccountPasswordPolicy",
				"iam:DeleteGroup",
				"iam:DeleteGroupPolicy",
				"iam:DeleteLoginProfile",
				"iam:DeleteOpenIDConnectProvider",
				"iam:DeleteSAMLProvider",
				"iam:DeleteUser",
				"iam:DeleteUserPermissionsBoundary",
				"iam:DeleteUserPolicy",
				"iam:DeleteVirtualMFADevice",
				"iam:DetachGroupPolicy",
				"iam:EnableMFADevice",
				"iam:PutGroupPolicy",
				"iam:PutUserPermissionsBoundary",
				"iam:RemoveClientIDFromOpenIDConnectProvider",
				"iam:RemoveUserFromGroup",
				"iam:ResyncMFADevice",
				"iam:UpdateAccountPasswordPolicy",
				"iam:UpdateGroup",
				"iam:UpdateLoginProfile",
				"iam:UpdateOpenIDConnectProviderThumbprint",
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
			"Sid": "DenyOrgRoleModification",
			"Effect": "Deny",
			"Action": [
				"iam:*"
			],
			"Resource": [
				"arn:aws:iam::*:role/OrgRole"
			]
		}
	]
}
POLICY


  denyexpensiveec2_policy = <<POLICY
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
		}
	]
}
POLICY


  denyvpncreation_policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
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
		}
	]
}
POLICY

}

