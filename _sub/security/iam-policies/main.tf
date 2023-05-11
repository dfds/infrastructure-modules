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

  statement {
    sid = "AssignPermissionSet"

    actions = [
      "sso:ListInstances",
      "identitystore:GetGroupId",
      "identitystore:DescribeGroup",
      "sso:ListPermissionSets",
      "sso:CreateAccountAssignment",
      "sso:DeleteAccountAssignment",
      "sso:DescribePermissionSet",
      "sso:ListTagsForResource",
      "sso:ListPermissionSetsProvisionedToAccount",
      "sso:ListAccountAssignments",
      "sso:DescribeAccountAssignmentCreationStatus",
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
    resources = var.core_account_role_arns
    effect    = "Deny"
  }

  statement {
    sid       = "DefaultAssumeAll"
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
    effect    = "Allow"
  }
}

data "aws_iam_policy_document" "access_cloudwatchlogs_capability" {
  statement {
    sid       = "GetLogStreamEvents"
    effect    = "Allow"
    actions   = ["logs:GetLogEvents"]
    resources = ["arn:aws:logs:*:*:log-group:/k8s/*/*:log-stream:*"]
  }

  statement {
    sid    = "ReadLogGroups"
    effect = "Allow"
    actions = [
      "logs:List*",
      "logs:Describe*",
      "logs:StartQuery",
      "logs:FilterLogEvents",
      "logs:Get*"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/k8s/*/*"]
  }

  statement {
    sid     = "DenySensitiveLogGroups"
    effect  = "Deny"
    actions = ["logs:*"]
    resources = [
      "arn:aws:logs:*:*:log-group:/k8s/*/kube-system:log-stream:*",
      "arn:aws:logs:*:*:log-group:/k8s/*/kube-system"
    ]
  }
}

data "aws_iam_policy_document" "access_cloudwatchlogs_devops" {
  statement {
    sid       = "GetLogStreamEvents"
    effect    = "Allow"
    actions   = ["logs:GetLogEvents"]
    resources = ["arn:aws:logs:*:*:log-group:/k8s/*/*:log-stream:*"]
  }

  statement {
    sid    = "ReadLogGroups"
    effect = "Allow"
    actions = [
      "logs:List*",
      "logs:Describe*",
      "logs:StartQuery",
      "logs:FilterLogEvents",
      "logs:Get*"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/k8s/*/*"]
  }
}

data "aws_iam_policy_document" "capability_access_shared" {
  statement {
    sid    = "GetParameters"
    effect = "Allow"
    actions = [
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/capabilities/${var.replace_token}/*",
      "arn:aws:ssm:*:*:parameter/shared/*"
    ]
  }

  statement {
    sid    = "DescribeParameters"
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters"
    ]
    resources = [
      "*"
    ]
  }
}

# SsoReader
data "aws_iam_policy_document" "ssoreader" {
  statement {
    sid    = "SsoReaderTf"
    effect = "Allow"
    actions = [
      "iam:ListRoles"
    ]
    resources = [
      "*"
    ]
  }
}

# ------------------------------------------------------------------------------
# Trusted Account
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "trusted_account" {
  count = signum(length(var.iam_role_trusted_account_root_arn))

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
      # force an interpolation expression to be interpreted as a list by wrapping it
      # in an extra set of list brackets. That form was supported for compatibility in
      # v0.11, but is no longer supported in Terraform v0.12.
      #
      # If the expression in the following list itself returns a list, remove the
      # brackets to avoid interpretation as a list of lists. If the expression
      # returns a single list item then leave it as-is and remove this TODO comment.
      identifiers = [element(var.iam_role_trusted_account_root_arn, 0)]
    }
  }
}
