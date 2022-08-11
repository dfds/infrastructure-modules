terraform {
  backend "s3" {}
}

provider "aws" {
  # default
  region  = var.aws_region
  version = "~> 3.75.0"
  max_retries = 3
}

provider "kubernetes" {
    config_path = local.kubeconfig_path
}

provider "helm" {
    kubernetes {
        config_path = local.kubeconfig_path
    }
}

locals {
  kubeconfig_path = "/home/paul/.kube/hellman-saml.config"
  serviceaccount_name = "subnet-exporter"
  deployment_name = "aws-subnet-exporter"
  iam_role_name = "SubnetExporter"
}

######### replace with Helm-chart #########################
# replace with single Helm release resource (chart)

resource "helm_release" "aws_subnet_exporter"{
    name = var.release_name
    chart= "aws-subnet-exporter"
    #chart= "/home/paul/Documents/helm-charts/charts/aws-subnet-exporter"
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
/*
resource "kubernetes_service_account" "this" {
  metadata {
    name = local.serviceaccount_name
    namespace = var.namespace_name
    annotations = {
      "eks.amazonaws.com/role-arn" = "reeee"
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = local.deployment_name
    namespace = var.namespace_name

    labels = {
      app = local.deployment_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.deployment_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.deployment_name
        }
      }

      spec {
        service_account_name = local.serviceaccount_name
        automount_service_account_token = true
        container {
          name  = local.deployment_name
          image = "dfdsdk/aws-subnet-exporter:${var.image_tag}"

          env {
            name  = "REGION"
            value = var.aws_region
          }

          env {
            name  = "FILTER"
            value = "*eks*"
          }

          env {
            name  = "PERIOD"
            value = "30s"
          }

          env {
            name  = "PORT"
            value = ":8080"
          }

          resources {
            requests = {
              cpu = "20m"

              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = local.deployment_name
    namespace = var.namespace_name

    labels = {
      app = local.deployment_name

      scrape-service-metrics = "true"
    }
  }

  spec {
    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = 8080
      target_port = "8080"
    }

    selector = {
      app = local.deployment_name
    }
  }
}*/

##################################################

