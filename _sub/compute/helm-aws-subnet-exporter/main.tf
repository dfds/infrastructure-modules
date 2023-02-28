terraform {
  backend "s3" {}
}

provider "aws" {
  region  = var.aws_region
  version = "~> 4.55.0"
  max_retries = 3
}

provider "kubernetes" {
    config_path = var.kubeconfig_path
}

provider "helm" {
    kubernetes {
        config_path = var.kubeconfig_path
    }
}

locals {
  serviceaccount_name = "subnet-exporter"
  deployment_name = "aws-subnet-exporter"
  iam_role_name = "SubnetExporter"
}

resource "helm_release" "aws_subnet_exporter"{
    name = var.release_name
    chart= "aws-subnet-exporter"
    repository = "https://dfds.github.io/helm-charts"
    version = var.chart_version
    namespace = var.namespace_name
    recreate_pods = true
    force_update  = false

    set {
        name  = "resources.requests.memory"
        value = "64Mi"
    }

    set{
        name = "resources.requests.cpu"
        value = "20m"
    }

    set{
        name = "image.repository"
        value= "dfdsdk/aws-subnet-exporter:0.3"
    }

}