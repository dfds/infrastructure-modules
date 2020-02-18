resource "kubernetes_namespace" "harbor" {
  count = var.deploy ? 1 : 0
  metadata {
    name = var.namespace

    annotations = {
      "iam.amazonaws.com/permitted" = element(concat(aws_iam_role.harbor.*.name, [""]), 0)
    }
  }

  provider = kubernetes
}

resource "kubernetes_config_map" "harbor-db-init" {
  count = var.deploy ? 1 : 0
  metadata {
    name      = "harbor-db-init-config"
    namespace = kubernetes_namespace.harbor[0].metadata[0].name
  }

  data = {
    "run.sh" = file("${path.module}/run.sh")
  }

  provider = kubernetes
}

resource "kubernetes_deployment" "harbor-db-init" {
  count = var.deploy ? 1 : 0
  metadata {
    name      = "harbor-db-init"
    namespace = kubernetes_namespace.harbor[0].metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "harbor-db-init"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          name = "harbor-db-init"
        }
      }

      spec {
        volume {
          name = "scripts"

          config_map {
            name         = kubernetes_config_map.harbor-db-init[0].metadata[0].name
            default_mode = 384
          }
        }

        container {
          name              = "harbor-db-init"
          image             = "alpine:3.5"
          image_pull_policy = "IfNotPresent"

          resources {
            requests {
              cpu    = "50m"
              memory = "64Mi"
            }
          }

          volume_mount {
            name       = "scripts"
            mount_path = "/scripts"
            read_only  = true
          }

          env {
            name  = "PGHOST"
            value = var.db_server_host
          }

          env {
            name  = "PGPORT"
            value = var.db_server_port
          }

          env {
            name  = "PGDATABASE"
            value = var.db_server_default_db_name
          }

          env {
            name  = "PGUSER"
            value = var.db_server_username
          }

          env {
            name  = "PGPASSWORD"
            value = var.db_server_password
          }

          command = [
            "/bin/sh",
          ]

          args = [
            "/scripts/run.sh",
          ]
        }
      }
    }
  }

  provider = kubernetes
}

