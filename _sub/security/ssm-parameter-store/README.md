# System Manager Parameter Store Terraform sub-module

## Required permissions

This module require permissions as specified in the following IAM policy document:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Manage",
            "Effect": "Allow",
            "Action": [
                "ssm:PutParameter",
                "ssm:ListTagsForResource",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/${Prefix}/*"
        },
        {
            "Sid": "Describe",
            "Effect": "Allow",
            "Action": "ssm:DescribeParameters",
            "Resource": "*"
        }
    ]
}
```
