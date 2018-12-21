resource "kubernetes_service_account" "traefik" {
  metadata {
    name      = "${var.traefik_k8s_name}-ingress-controller"
    namespace = "kube-system"
  }
  provider = "kubernetes"
}

resource "kubernetes_deployment" "traefik" {
  metadata {
    name      = "${var.traefik_k8s_name}-ingress-controller"
    namespace = "kube-system"

    labels {
      k8s-app = "${var.traefik_k8s_name}"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels {
        k8s-app = "${var.traefik_k8s_name}"
      }
    }

    template {
      metadata {
        labels {
          k8s-app = "${var.traefik_k8s_name}"
          name    = "${var.traefik_k8s_name}"
        }
      }

      spec {
        service_account_name             = "${var.traefik_k8s_name}-ingress-controller"
        termination_grace_period_seconds = 60

        container {
          image = "traefik"
          name  = "${var.traefik_k8s_name}"

          port {
            name           = "http"
            container_port = 80
          }

          port {
            name           = "admin"
            container_port = 8080
          }

          args = ["--api", "--kubernetes", "--logLevel=INFO"]
        }
      }
    }
  }
  provider = "kubernetes"
}

resource "kubernetes_service" "traefik" {
  metadata {
    name      = "${var.traefik_k8s_name}-ingress-service"
    namespace = "kube-system"
  }

  spec {
    selector {
      k8s-app = "${var.traefik_k8s_name}"
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
  provider = "kubernetes"
}