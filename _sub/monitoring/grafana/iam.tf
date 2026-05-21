# --------------------------------------------------
# IAM Roles for ServiceAccounts (IRSA) for Grafana
# --------------------------------------------------

locals {
  iam_role_name = "${local.deploy_name}-irsa"
  oidc_issuer  = trim(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://")
}

# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "ssm" {
  statement {
    actions   = ["ssm:GetParameter*", "ssm:DescribeParameters", "tag:GetResources"]
    effect    = "Allow"
    resources = ["arn:aws:ssm:${data.aws_region.this.region}:${data.aws_caller_identity.this.id}:paramete*"] # TODO: make it more restrictive to only allow access to the specific /eks/<cluster_name>/1password-connect-token-grafana parameter
  }
}

resource "aws_iam_policy" "this" {
  name        = "${local.iam_role_name}-policy"
  description = "Used for IRSA by Grafana"
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
      values   = ["system:serviceaccount:grafana:${local.deploy_name}"]
      variable = "${local.oidc_issuer}:sub"
    }
  }
}

resource "aws_iam_role" "this" {
  name               = local.iam_role_name
  description        = "Used for IRSA by Grafana"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}


module "irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.6.0"

  name = "test_grafana_1password" #local.iam_role_name

  oidc_providers = {
    one = {
      provider_arn               = "arn:aws:iam::${data.aws_caller_identity.this.id}:oidc-provider/${local.oidc_issuer}"
      namespace_service_accounts = ["grafana:${local.deploy_name}"]
    }
  }

  inline_policy_permissions = [
    {
      name        = "AllowReadSSMParameters"
      description = "Allow read access to SSM parameters for Grafana"
      actions     = ["ssm:GetParameter*", "ssm:DescribeParameters", "tag:GetResources"]
      resources   = ["arn:aws:ssm:${data.aws_region.this.region}:${data.aws_caller_identity.this.id}:paramete*"] # TODO: make it more restrictive to only allow access to the specific /eks/<cluster_name>/1password-connect-token-grafana parameter
    }
  ]
}