resource "aws_iam_openid_connect_provider" "github" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
  url             = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "this" {
  name               = "oidc-role"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

data "aws_iam_policy_document" "trust" {
  statement {
    effect = "Allow"
    principals {
      identifiers = [aws_iam_openid_connect_provider.github.arn]
      type        = "Federated"
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }
    condition {
      test     = "StringLike"
      values   = flatten([for k, v in { for repo in var.repositories : repo.repository_name => repo.branches } : formatlist("repo:%s:ref:refs/heads/%s", k, v)])
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "oidc-access"
  policy = data.aws_iam_policy_document.oidc_access.json
  role   = aws_iam_role.this.id
}

data "aws_iam_policy_document" "oidc_access" {
  dynamic "statement" {
    for_each = var.oidc_role_access
    content {
      effect    = "Allow"
      actions   = statement.value["actions"]
      resources = statement.value["resources"]
    }
  }
}
