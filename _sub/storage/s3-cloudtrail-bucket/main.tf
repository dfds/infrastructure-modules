resource "aws_s3_bucket" "bucket" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = var.s3_bucket
  tags = {
    "Managed by" = "Terraform"
  }

  force_destroy = true
  policy        = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.s3_bucket}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.s3_bucket}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
  ]
}
POLICY


  lifecycle_rule {
    enabled                                = true
    id                                     = "cloudtrail_logs_retention_policy"
    abort_incomplete_multipart_upload_days = var.retention_days

    expiration {
      days = var.retention_days
    }

    noncurrent_version_expiration {
      days = var.retention_days
    }
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.bucket[count.index].id
  acl    = "private"
}
