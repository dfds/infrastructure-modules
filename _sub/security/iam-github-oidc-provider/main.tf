resource "aws_iam_openid_connect_provider" "github" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1", # pragma: allowlist secret
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"  # pragma: allowlist secret
  ]
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "this" {
  name               = var.oidc_role_name
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
      values   = flatten([for k, v in { for repo in var.repositories : repo.repository_name => repo.refs } : formatlist("repo:%s:%s", k, v)])
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

resource "aws_iam_role_policy" "this" {
  name   = var.oidc_policy_name
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
