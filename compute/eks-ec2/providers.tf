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

provider "kubernetes" {
  host                   = module.eks_cluster.eks_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.eks_certificate_authority)

  exec {
    api_version = var.eks_k8s_auth_api_version
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      var.eks_cluster_name,
      "--region",
      var.aws_region,
      "--role-arn",
      var.aws_assume_role_arn,
    ]
  }
}
