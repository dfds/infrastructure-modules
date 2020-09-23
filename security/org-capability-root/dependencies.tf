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
                "budgets:*",
                "cloudfront:*",
                "globalaccelerator:*",
                "iam:*",
                "sts:*",
                "importexport:*",
                "kms:*",
                "lambda:*",
                "organizations:*",
                "route53:*",
                "support:*",
                "waf:*",
                "shield:*",
                "s3:List*",
                "dynamoDB:DescribeTable",
                "aws-portal:View*",
                "cloudwatch:List*",
                "cloudwatch:Get*",
                "ecr:Get*",
                "ecr:List*",
                "ecr:Describe*",
                "ecr:BatchGetImage"
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
			"Sid": "DenyIAM",
			"Effect": "Deny",
			"Action": [
				"iam:CreateSAMLProvider",
				"iam:CreateUser",
				"iam:CreateGroup",
				"iam:CreateAccountAlias",
				"iam:UpdateUser",
				"iam:UpdateGroup",
				"iam:UpdateSAMLProvider",
				"iam:DeleteAccountAlias",
				"iam:DeleteAccountPasswordPolicy",
				"iam:DeleteGroup",
				"iam:DeleteSAMLProvider",
				"iam:DeleteUser",
				"iam:UpdateAccountPasswordPolicy",
				"iam:RemoveUserFromGroup",
				"iam:AttachGroupPolicy",
				"iam:AddUserToGroup",
				"iam:DeleteGroupPolicy",
				"iam:DetachGroupPolicy",
				"iam:DetachUserPolicy",
				"iam:DeleteUserPolicy",
				"iam:DeleteUserPermissionsBoundary",
				"iam:TagUser",
				"iam:UntagUser",
				"iam:UpdateAccessKey",
				"iam:UpdateLoginProfile",
				"iam:UpdateOpenIDConnectProviderThumbprint",
				"iam:AddClientIDToOpenIDConnectProvider",
				"iam:CreateAccessKey",
				"iam:ChangePassword",
				"iam:AttachUserPolicy",
				"iam:CreateLoginProfile",
				"iam:CreateOpenIDConnectProvider",
				"iam:CreateVirtualMFADevice",
				"iam:DeactivateMFADevice",
				"iam:DeleteAccessKey",
				"iam:DeleteLoginProfile",
				"iam:DeleteOpenIDConnectProvider",
				"iam:DeleteVirtualMFADevice",
				"iam:EnableMFADevice",
				"iam:PutUserPermissionsBoundary",
				"iam:PutGroupPolicy",
				"iam:PutUserPolicy",
				"iam:RemoveClientIDFromOpenIDConnectProvider",
				"iam:ResyncMFADevice"
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

