# ------------------------------------------------------------------------------
# DEFINE IAM POLICIES
# ------------------------------------------------------------------------------

# Admin
data "aws_iam_policy_document" "admin" {
  statement {
    sid       = "Admin"
    actions   = ["*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

# Create Route53 Zone
data "aws_iam_policy_document" "create_route53_zone" {
  statement {
    sid       = "Route53CreateZone"
    actions   = ["CreateHostedZone"]
    resources = ["*"]
    effect    = "Allow"
  }
}

# Push to (and pull from) ECR
data "aws_iam_policy_document" "push_to_ecr" {
  statement {
    sid = "ECRPush"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

# Create S3 Bucket
data "aws_iam_policy_document" "create_s3_bucket" {
  statement {
    sid = "S3CreateBucket"

    actions = [
      "s3:PutBucketPolicy",
      "s3:CreateBucket",
      "s3:PutBucketVersioning",
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
    sid = "OrgCreateAccount"

    actions = [
      "organizations:CreateAccount",
      "organizations:DescribeAccount",
      "organizations:DescribeCreateAccountStatus",
      "organizations:ListAccounts",
      "organizations:ListAccountsForParent",
      "organizations:ListParents",
      "organizations:ListRoots",
      "organizations:ListTagsForResource",
      "organizations:MoveAccount",
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
