# ------------------------------------------------------------------------------
# DEFINE IAM POLICIES
# ------------------------------------------------------------------------------


# Create Route53 Zone
data "aws_iam_policy_document" "create_route53_zone" {
    statement {
        sid       = "Route53CreateZone"
        actions   = ["CreateHostedZone"]
        resources = ["*"]
        effect    = "Allow"
    }
}


# Create S3 Bucket
data "aws_iam_policy_document" "create_s3_bucket" {
    statement {
        sid       = "S3CreateBucket"
        actions   = [
                "s3:PutBucketPolicy",
                "s3:CreateBucket",
                "s3:PutBucketVersioning"
            ]
        resources = ["*"]
        effect    = "Allow"
    }
}


# Create Org. Account
data "aws_iam_policy_document" "create_org_account" {
    statement {
        sid       = "OrgCreateAccount"
        actions   = [
                "organizations:CreateAccount",
                "organizations:GetAccount"
            ]
        resources = ["*"]
        effect    = "Allow"
    }
}


# ------------------------------------------------------------------------------
# Trusted Account
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "trusted_account" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.iam_role_trusted_account}:root"]
    }

  }
}