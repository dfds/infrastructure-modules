data "aws_iam_policy_document" "this" {
  statement {
    sid    = "AWSConfigAclCheck"
    effect = "Allow"
    principals {
      identifiers = [
        "config.amazonaws.com"
      ]
      type = "Service"
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket}"
    ]
  }

  statement {
    sid    = "AWSConfigExistinceCheck"
    effect = "Allow"
    principals {
      identifiers = [
        "config.amazonaws.com"
      ]
      type = "Service"
    }
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket}"
    ]
  }


  statement {
    sid    = "AWSConfigWrite"
    effect = "Allow"
    principals {
      identifiers = [
        "config.amazonaws.com"
      ]
      type = "Service"
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket}/*"
    ]
    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
  }
}
