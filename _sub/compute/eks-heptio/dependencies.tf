# --------------------------------------------------
# Region
# --------------------------------------------------

data "aws_region" "current" {}

# --------------------------------------------------
# Kubeconfig
# --------------------------------------------------

locals {
  temp_kubeconfig_path = "./kube_${var.cluster_name}.config"
}

data "template_file" "kubeconfig_admin" {
  template = file("${path.module}/kubeconfig-admin.yaml")
  vars = {
    cluster_name = var.cluster_name
    endpoint     = var.eks_endpoint
    ca           = var.eks_certificate_authority
    role_arn     = var.aws_assume_role_arn
    aws_region   = data.aws_region.current.name
  }
}

data "template_file" "kubeconfig_saml" {
  template = file("${path.module}/kubeconfig-saml.yaml")
  vars = {
    cluster_name = var.cluster_name
    endpoint     = var.eks_endpoint
    ca           = var.eks_certificate_authority
  }
}


# --------------------------------------------------
# AWS auth configmap
# --------------------------------------------------

data "template_file" "default_auth_cm" {
  template = file("${path.module}/default-auth-cm.yaml")
  vars = {
    role_arn = var.eks_role_arn
  }
}