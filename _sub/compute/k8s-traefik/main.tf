resource "kubernetes_cluster_role" "traefik" {
  count = var.deploy ? 1 : 0
  metadata {
    name = "${var.deploy_name}-cr"
  }
  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "secrets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }
}


resource "kubernetes_service_account" "traefik" {
  count = var.deploy ? 1 : 0
  metadata {
    name      = "${var.deploy_name}-sa"
    namespace = var.namespace
  }
}


resource "kubernetes_cluster_role_binding" "traefik" {
  count = var.deploy ? 1 : 0
  metadata {
    name = "${var.deploy_name}-crb"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.traefik[0].metadata[0].name
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.traefik[0].metadata[0].name
    namespace = kubernetes_service_account.traefik[0].metadata[0].namespace
  }
}


resource "kubernetes_deployment" "traefik" {
  count = var.deploy ? 1 : 0
  metadata {
    name      = var.deploy_name
    namespace = var.namespace

    labels = {
      k8s-app = local.label_k8s-app
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        k8s-app = local.label_k8s-app
      }
    }

    template {
      metadata {
        labels = {
          name    = var.deploy_name
          k8s-app = local.label_k8s-app
        }
      }

      spec {
        priority_class_name              = var.priority_class
        service_account_name             = kubernetes_service_account.traefik[0].metadata[0].name
        termination_grace_period_seconds = 60

        volume {
          name = kubernetes_service_account.traefik[0].default_secret_name
          secret {
            secret_name = kubernetes_service_account.traefik[0].default_secret_name
          }
        }

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key = "k8s-app"
                  operator = "In"
                  values = [local.label_k8s-app]
                }
              }
              topology_key = "failure-domain.beta.kubernetes.io/zone"
            }
          }
        }

        container {
          image = "traefik:v${var.image_version}"
          name  = "traefik"

          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = kubernetes_service_account.traefik[0].default_secret_name
            read_only  = true
          }

          port {
            name           = local.http_name
            container_port = local.http_port
          }

          port {
            name           = local.admin_name
            container_port = local.admin_port
          }

          args = [
            "--api",
            "--kubernetes",
            "--logLevel=INFO",
            "--metrics.prometheus",
            "--accessLog.format=json",
            "--accessLog.filters.statusCodes='300-399,400-499,500-599'"
          ]
        }
      }
    }
  }
}


resource "kubernetes_service" "traefik" {
  count = var.deploy ? 1 : 0
  metadata {
    name      = var.deploy_name
    namespace = var.namespace
    annotations = {
      "prometheus.io/port"   = local.admin_port
      "prometheus.io/scrape" = "true"
    }
    labels = {
      scrape-service-metrics = "true"
    }
  }

  spec {
    selector = {
      k8s-app = local.label_k8s-app
    }

    port {
      protocol    = "TCP"
      port        = local.http_port
      node_port   = var.http_nodeport
      target_port = local.http_port
      name        = "web"
    }

    port {
      protocol    = "TCP"
      port        = local.admin_port
      node_port   = var.admin_nodeport
      target_port = local.admin_port
      name        = local.admin_name
    }

    type = "NodePort"
  }
}
