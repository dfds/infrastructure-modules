# --------------------------------------------------
# IAM Roles for ServiceAccounts (IRSA) for 1Password connect server
# --------------------------------------------------

locals {
  iam_role_name = "${local.deploy_name}-irsa"
}

# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "ssm" {
  statement {
    actions   = ["ssm:GetParameter*", "ssm:DescribeParameters", "tag:GetResources"]
    effect    = "Allow"
    resources = ["arn:aws:ssm:${var.aws_region}:${var.workload_account_id}:parameter/1password-connect/*"]
  }
}

resource "aws_iam_policy" "this" {
  name        = "${local.iam_role_name}-policy"
  description = "Used for IRSA by 1Password connect server"
  policy      = data.aws_iam_policy_document.ssm.json
}

data "aws_iam_policy_document" "trust" {
  statement {
    sid     = "AssumeRoleWithWebIdentity"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        "arn:aws:iam::${var.workload_account_id}:oidc-provider/${var.oidc_issuer}",
      ]
    }

    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:1password-connect:${local.deploy_name}"]
      variable = "${var.oidc_issuer}:sub"
    }
  }
}

resource "aws_iam_role" "this" {
  name               = local.iam_role_name
  description        = "Used for IRSA by 1Password connect server"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
