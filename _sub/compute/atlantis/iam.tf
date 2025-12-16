# --------------------------------------------------
# IAM Roles for ServiceAccounts (IRSA) for Atlantis
# --------------------------------------------------

locals {
  iam_role_name = "${local.deploy_name}-irsa"
}

# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "ssm" {
  statement {
    actions   = ["ssm:GetParameter*", "ssm:DescribeParameters", "tag:GetResources"]
    effect    = "Allow"
    resources = ["arn:aws:ssm:${data.aws_region.this.region}:${data.aws_caller_identity.this.id}:parameter*"]
  }
}

resource "aws_iam_policy" "this" {
  name        = "${local.iam_role_name}-policy"
  description = "Used for IRSA by Atlantis"
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
        "arn:aws:iam::${data.aws_caller_identity.this.id}:oidc-provider/${local.oidc_issuer}",
      ]
    }

    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:atlantis:${local.deploy_name}"]
      variable = "${local.oidc_issuer}:sub"
    }
  }
}

resource "aws_iam_role" "this" {
  name               = local.iam_role_name
  description        = "Used for IRSA by Atlantis"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
