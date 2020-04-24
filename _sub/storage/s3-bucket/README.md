## Required permissions

This module require permissions as specified in the following IAM policy document:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutBucketTagging",
                "s3:PutBucketAcl",
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:DeleteBucketPolicy"
            ],
            "Resource": "arn:aws:s3:::${BucketName}"
        }
    ]
}
```
