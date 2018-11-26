provider "aws" {
  # The AWS region in which all resources will be created
  region = "${var.aws_region}"

  version = "~> 1.40"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend          "s3"             {}
  required_version = "~> 0.11.7"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.cloudtrail_s3_bucket}"
  acl    = "private"
  tags = {
      "Managed by" = "Terraform"
  }

  force_destroy = true
  policy = <<POLICY
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
            "Resource": "arn:aws:s3:::${var.cloudtrail_s3_bucket}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.cloudtrail_s3_bucket}/*",
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
    enabled = true
    id = "cloudtrail_logs_retention_policy"    
    abort_incomplete_multipart_upload_days = "${var.cloudtrail_logs_retention}"

    expiration {
      days = "${var.cloudtrail_logs_retention}"
    }

    noncurrent_version_expiration {
      days = "${var.cloudtrail_logs_retention}"
    }
  }
}
