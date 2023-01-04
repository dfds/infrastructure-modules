# --------------------------------------------------
# Region
# --------------------------------------------------

data "aws_region" "current" {}

# --------------------------------------------------
# Kubeconfig
# --------------------------------------------------

locals {
  temp_kubeconfig_path = "./kube_${var.cluster_name}.config"
  kubeconfig_admin_template = templatefile(
    "${path.module}/kubeconfig-admin.yaml",
    {
      cluster_name     = var.cluster_name
      endpoint         = var.eks_endpoint
      ca               = var.eks_certificate_authority
      role_arn         = var.aws_assume_role_arn
      aws_region       = data.aws_region.current.name
      auth_api_version = var.eks_k8s_auth_api_version
    }
  )
  kubeconfig_saml_template = templatefile(
    "${path.module}/kubeconfig-saml.yaml",
    {
      cluster_name     = var.cluster_name
      endpoint         = var.eks_endpoint
      ca               = var.eks_certificate_authority
      auth_api_version = var.eks_k8s_auth_api_version
    }
  )
}


# --------------------------------------------------
# AWS auth configmap
# --------------------------------------------------

locals {
  default_auth_cm_template = templatefile(
    "${path.module}/default-auth-cm.yaml",
    {
      role_arn = var.eks_role_arn
    }
  )
}
