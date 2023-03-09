# --------------------------------------------------
# OIDC Provider URL
# --------------------------------------------------

# When var.eks_cluster_name is supplied, we will use
# the EKS data provider to fetch the oidc_provider_url
# Since data providers don't work across accounts,
# using var.eks_cluster_name only make sense if the
# EKS cluster and the S3 bucket for Velero are in
# the same AWS account.
#
# Hence for our sandbox environments and QA:
# 1. ONLY provide var.eks_cluster_name AND var.bucket_name
#
# For our production environments:
# 1. ONLY provide var.oidc_provider_url AND var.bucket_name

data "aws_eks_cluster" "eks" {
  count = var.eks_cluster_name != null ? 1 : 0
  name  = var.eks_cluster_name
}

locals {
  oidc_provider_url = var.oidc_provider_url == null ? (
    data.aws_eks_cluster.eks[0].identity[0].oidc[0].issuer) : (
    var.oidc_provider_url
  )
}

# --------------------------------------------------
# Caller identity and additional OIDC properties
# --------------------------------------------------

data "aws_caller_identity" "current" {}

locals {
  account_id              = data.aws_caller_identity.current.account_id
  oidc_provider_server_id = trim(local.oidc_provider_url, "https://")
  oidc_provider_arn       = "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc_provider_server_id}"
}
