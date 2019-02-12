resource "kubernetes_namespace" "harbor" {
  count = "${var.deploy}"
  metadata {
    name = "${var.harbor_k8s_namespace}"
  }

  provider = "kubernetes"
}

resource "kubernetes_config_map" "harbor-db-init" {
  count = "${var.deploy}"
  metadata {
    name      = "harbor-db-init-config"
    namespace = "${kubernetes_namespace.harbor.metadata.0.name}"
  }

  data {
    run.sh = "${path.module}/run.sh"
  }

  provider = "kubernetes"
}

resource "kubernetes_deployment" "harbor-db-init" {
  count = "${var.deploy}"
  metadata {
    name      = "harbor-db-init"
    namespace = "${kubernetes_namespace.harbor.metadata.0.name}"
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        name = "harbor-db-init"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels {
          name = "harbor-db-init"
        }
      }

      spec {
        volume {
          name = "scripts"

          config_map {
            name         = "${kubernetes_config_map.harbor-db-init.metadata.0.name}"
            default_mode = 0600
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
            value = "${aws_db_instance.instance.address}"
          }

          env {
            name  = "PGPORT"
            value = "${var.port}"
          }

          env {
            name  = "PGDATABASE"
            value = "${var.db_name}"
          }

          env {
            name  = "PGUSER"
            value = "${var.db_username}"
          }

          env {
            name  = "PGPASSWORD"
            value = "${var.db_password}"
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

  #   depends_on = ["kubernetes_namespace.harbor"]
  provider = "kubernetes"
}
