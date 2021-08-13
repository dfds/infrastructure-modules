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

    strategy {
      rolling_update {
        max_unavailable = 1 # Default is 25%. With 3 replicas, due to anti-affinity, this means the pods cannot be scheduled, when the deployment is updated
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

        # Attempt to spread pods over different availability zones, but still schedule all pods if a zone is unavailable
        # https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
        topology_spread_constraint {
          topology_key       = "topology.kubernetes.io/zone"
          when_unsatisfiable = "ScheduleAnyway"
          label_selector {
            match_labels = {
              k8s-app = local.label_k8s-app
            }
          }
        }

        topology_spread_constraint {
          topology_key       = "kubernetes.io/hostname"
          when_unsatisfiable = "DoNotSchedule"
          max_skew           = 1 # allow rolling updates on minimal clusters

          label_selector {
            match_labels = {
              k8s-app = local.label_k8s-app
            }
          }
        }

        container {
          image = "traefik:v${var.image_version}"
          name  = "traefik"

          resources {
            requests = {
              cpu    = var.request_cpu
              memory = var.request_memory
            }
          }

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

# --------------------------------------------------
# Generate random password and create a hash for it
# --------------------------------------------------

resource "random_password" "password" {
  count            = var.dashboard_deploy ? 1 : 0
  length           = 32
  special          = true
  override_special = "!@#$%&*-_=+:?"
}

resource "htpasswd_password" "hash" {
  count    = var.dashboard_deploy ? 1 : 0
  password = random_password.password[0].result
  salt     = substr(sha512(random_password.password[0].result), 0, 8)
}

# --------------------------------------------------
# Save username and hashed password in a k8s secret
# --------------------------------------------------
resource "kubernetes_secret" "secret" {
  count = var.dashboard_deploy ? 1 : 0
  metadata {
    name      = local.dashboard_secret_name
    namespace = var.namespace
  }

  data = {
    auth = "${var.dashboard_username}:${htpasswd_password.hash[0].apr1}"
  }
}

# --------------------------------------------------
# Save password in AWS Parameter Store
# --------------------------------------------------
resource "aws_ssm_parameter" "param_traefik_dashboard" {
  count       = var.dashboard_deploy ? 1 : 0
  name        = "/eks/${var.cluster_name}/traefik-legacy-dashboard"
  description = "Password for accessing the Traefik dashboard"
  type        = "SecureString"
  value       = random_password.password[0].result
  overwrite   = true
}

# --------------------------------------------------
# Ingress to Traefik. Secured by Basic Auth
# --------------------------------------------------
resource "kubernetes_ingress" "ingress" {
  count = var.dashboard_deploy ? 1 : 0

  metadata {
    name        = local.dashboard_ingress_name
    namespace   = var.namespace
    annotations = local.dashboard_ingress_annotations
    labels      = local.dashboard_ingress_labels
  }

  spec {
    rule {
      host = var.dashboard_ingress_host
      http {
        path {
          path = var.dashboard_ingress_backend_path
          backend {
            service_name = var.deploy_name
            service_port = local.admin_port
          }
        }
      }
    }
  }
}
