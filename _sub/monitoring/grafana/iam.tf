# --------------------------------------------------
# IAM Roles for ServiceAccounts (IRSA) for Grafana
# --------------------------------------------------

locals {
  oidc_issuer = trim(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://")
}

module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.6.1"

  name            = "${local.deploy_name}-${var.cluster_name}-irsa"
  use_name_prefix = false
  description     = "Used for IRSA by Grafana"

  oidc_providers = {
    one = {
      provider_arn               = "arn:aws:iam::${data.aws_caller_identity.this.id}:oidc-provider/${local.oidc_issuer}"
      namespace_service_accounts = ["grafana:${local.deploy_name}"]
    }
  }

  permissions = {
    AllowReadSSMParameters = {
      sid       = "AllowReadSSMParameters"
      actions   = ["ssm:GetParameter*", "ssm:DescribeParameters", "tag:GetResources"]
      effect    = "Allow"
      resources = [var.onepassword_access_parameter_store_arn]
    }
  }
}
