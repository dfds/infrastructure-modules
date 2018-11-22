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
# Seems to be enough permissions to *create* account, but not get status on creation, resulting in repeated attempts
# May have been fixed by adding "organizations:DescribeCreateAccountStatus", "organizations:DescribeAccount"
data "aws_iam_policy_document" "create_org_account" {
    statement {
        sid       = "OrgCreateAccount"
        actions   = [
                "organizations:ListAccounts",
                "organizations:CreateAccount",
                "organizations:DescribeAccount",
                "organizations:DescribeCreateAccountStatus"
            ]
        resources = ["*"]
        effect    = "Allow"
    }
}


# Assume Non-core Accounts
data "aws_iam_policy_document" "assume_noncore_accounts" {

    statement {
        sid       = "DoNotAssumeCore"
        actions   = ["sts:AssumeRole"]
        resources = ["${var.core_account_role_arns}"]
        effect    = "Deny"
    }

    statement {
        sid       = "DefaultAssumeAll"
        actions   = ["sts:AssumeRole"]
        resources = ["*"]
        effect    = "Allow"
    }

}



# ------------------------------------------------------------------------------
# Trusted Account
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "trusted_account" {

    count = "${signum(length(var.iam_role_trusted_account_root_arn))}"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["${element(var.iam_role_trusted_account_root_arn, 0)}"]
    }

  }
}