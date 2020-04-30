resource "kubernetes_service_account" "traefik" {
  count = var.deploy ? 1 : 0
  metadata {
    name      = "${var.deploy_name}-ingress-controller"
    namespace = var.namespace
  }
  provider = kubernetes
}

resource "kubernetes_deployment" "traefik" {
  count = var.deploy ? 1 : 0
  metadata {
    name      = "${var.deploy_name}-ingress-controller"
    namespace = var.namespace

    labels = {
      k8s-app = var.deploy_name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        k8s-app = var.deploy_name
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = var.deploy_name
          name    = var.deploy_name
        }
      }

      spec {
        service_account_name             = "${var.deploy_name}-ingress-controller"
        termination_grace_period_seconds = 60
        volume {
          name = kubernetes_service_account.traefik[0].default_secret_name
          secret {
            secret_name = kubernetes_service_account.traefik[0].default_secret_name
          }
        }

        container {
          image = "traefik:v${var.image_version}"
          name  = var.deploy_name

          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = kubernetes_service_account.traefik[0].default_secret_name
            read_only  = true
          }

          port {
            name           = "http"
            container_port = 80
          }

          port {
            name           = "admin"
            container_port = 8080
          }

          args = ["--api", "--kubernetes", "--logLevel=INFO", "--metrics.prometheus", "--accessLog.format=json", "--accessLog.filters.statusCodes='300-399,400-499,500-599'"]
        }
      }
    }
  }
  provider = kubernetes
}

resource "kubernetes_service" "traefik" {
  count = var.deploy ? 1 : 0
  metadata {
    name      = var.deploy_name
    namespace = var.namespace
    annotations = {
      "prometheus.io/port"   = "8080"
      "prometheus.io/scrape" = "true"
    }
    labels = {
      scrape-service-metrics = "true"
    }
  }

  spec {
    selector = {
      k8s-app = var.deploy_name
    }

    port {
      protocol    = "TCP"
      port        = 80
      node_port   = 30000
      target_port = 80
      name        = "web"
    }

    port {
      protocol    = "TCP"
      port        = 8080
      node_port   = 30001
      target_port = 8080
      name        = "admin"
    }

    type = "NodePort"
  }
  provider = kubernetes
}


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

resource "kubernetes_cluster_role_binding" "example" {
  count = var.deploy ? 1 : 0
  metadata {
    name = "${var.deploy_name}-ingress-controller"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "traefik-ingress-controller"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "${var.deploy_name}-cr"
    namespace = var.namespace
  }
}

