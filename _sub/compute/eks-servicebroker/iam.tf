resource "aws_iam_role_policy" "allow_dynamodb_access" {
  name = "grant_dynamodb_access"
  role = "${var.worker_role_id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
         "s3:GetObject",
         "s3:ListBucket"
      ],
      "Resource": [
         "arn:aws:s3:::awsservicebroker/templates/*",
         "arn:aws:s3:::awsservicebroker"
      ],
      "Effect": "Allow"
    },
    {
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:${var.aws_region}:${var.workload_account_id}:table/${var.table_name}",
      "Effect": "Allow"
    },
    {
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": [
          "arn:aws:ssm:${var.aws_region}:${var.workload_account_id}:parameter/asb-*",
          "arn:aws:ssm:${var.aws_region}:${var.workload_account_id}:parameter/Asb*"
      ],
      "Effect": "Allow"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "allow_resource_provisioning" {
  name = "allow_resource_provisioning"
  role = "${var.worker_role_id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "SsmForSecretBindings",
        "Action": "ssm:PutParameter",
        "Resource": "arn:aws:ssm:${var.aws_region}:${var.workload_account_id}:parameter/asb-*",
        "Effect": "Allow"
      },
      {
        "Sid": "AllowCfnToGetTemplates",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::awsservicebroker/templates/*",
        "Effect": "Allow"
      },
      {
         "Sid": "CloudFormation",
         "Action": [
            "cloudformation:CreateStack",
            "cloudformation:DeleteStack",
            "cloudformation:DescribeStacks",
            "cloudformation:UpdateStack",
            "cloudformation:CancelUpdateStack"
         ],
         "Resource": [
            "arn:aws:cloudformation:${var.aws_region}:${var.workload_account_id}:stack/aws-service-broker-*/*"
         ],
         "Effect": "Allow"
      },
     {
        "Sid": "ServiceClassPermissions",
        "Action": [
           "athena:*",
           "dynamodb:*",
           "kms:*",
           "elasticache:*",
           "elasticmapreduce:*",
           "kinesis:*",
           "rds:*",
           "redshift:*",
           "route53:*",
           "s3:*",
           "sns:*",
           "sqs:*",
           "ec2:*",
           "iam:*",
           "lambda:*"
        ],
        "Resource": [
           "*"
        ],
        "Effect": "Allow"
     }
   ]
}
POLICY
}