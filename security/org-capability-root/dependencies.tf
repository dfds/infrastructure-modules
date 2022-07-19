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
				"iam:DeleteLoginProfile",
				"iam:DeleteSAMLProvider",
				"iam:DeleteUser",
				"iam:DeleteUserPermissionsBoundary",
				"iam:DeleteUserPolicy",
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

