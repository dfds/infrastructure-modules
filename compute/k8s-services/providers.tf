terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "core"
}

locals {
  aws_assume_logs_role_arn = var.aws_assume_logs_role_arn == null || var.aws_assume_logs_role_arn == "" ? var.aws_assume_role_arn : var.aws_assume_logs_role_arn
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = local.aws_assume_logs_role_arn
  }

  alias = "logs"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
  # config_path            = pathexpand("~/.kube/${var.eks_cluster_name}.config") # no datasources in providers allowed when importing into state (remember to flip above bool to load config)
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
    # config_path            = pathexpand("~/.kube/${var.eks_cluster_name}.config") # no datasources in providers allowed when importing into state (remember to flip above bool to load config)
  }
}

provider "github" {
  token = var.atlantis_github_token
  owner = var.atlantis_github_owner
  alias = "atlantis"
}

provider "github" {
  token = var.fluxcd_bootstrap_repo_owner_token
  owner = var.fluxcd_bootstrap_repo_owner
  alias = "fluxcd"
}

provider "random" {
}

provider "azuread" {

}
