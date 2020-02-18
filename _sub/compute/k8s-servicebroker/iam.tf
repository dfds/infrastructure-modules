resource "aws_iam_role" "servicebroker_role" {
  count       = var.deploy ? 1 : 0
  name        = "eks-${var.cluster_name}-servicebroker"
  description = "Role the ServiceBroker process assumes"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_workload_account_id}:role/${var.kiam_server_role_id}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "allow_dynamodb_access" {
  count = var.deploy ? 1 : 0
  name  = "grant_dynamodb_access"
  role  = aws_iam_role.servicebroker_role[0].id

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
      "Resource": "arn:aws:dynamodb:${var.aws_region}:${var.aws_workload_account_id}:table/${var.table_name}",
      "Effect": "Allow"
    },
    {
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": [
          "arn:aws:ssm:${var.aws_region}:${var.aws_workload_account_id}:parameter/asb-*",
          "arn:aws:ssm:${var.aws_region}:${var.aws_workload_account_id}:parameter/Asb*"
      ],
      "Effect": "Allow"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy" "allow_resource_provisioning" {
  count = var.deploy ? 1 : 0
  name  = "allow_resource_provisioning"
  role  = aws_iam_role.servicebroker_role[0].id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "SsmForSecretBindings",
        "Action": "ssm:PutParameter",
        "Resource": "arn:aws:ssm:${var.aws_region}:${var.aws_workload_account_id}:parameter/asb-*",
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
            "arn:aws:cloudformation:${var.aws_region}:${var.aws_workload_account_id}:stack/aws-service-broker-*/*"
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

