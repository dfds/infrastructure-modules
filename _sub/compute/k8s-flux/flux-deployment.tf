resource "kubernetes_namespace" "flux_namespace" {
  count = var.deploy ? 1 : 0

  metadata {
    name = var.namespace
  }

  provider = kubernetes
}

resource "kubernetes_deployment" "flux" {
  count = var.deploy ? 1 : 0

  metadata {
    name      = "flux"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "flux"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        annotations = {
          "prometheus.io.port" = "3031" # tell prometheus to scrape /metrics endpoint's port.
        }

        labels = {
          name = "flux"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.flux[0].metadata[0].name

        volume {
          name = "git-key"

          secret {
            secret_name  = kubernetes_secret.flux-git-deploy[0].metadata[0].name
            default_mode = 256
          }
        }

        volume {
          name = "git-keygen"

          empty_dir {
            medium = "Memory"
          }
        }

        # This work around solves the issue with terraform is aut-setting this attribute spec.template.spec.automountServiceAccountToken: false
        # which prevents pod from accessing the API and causes flux pod to fail
        # https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#use-the-default-service-account-to-access-the-api-server
        # Solution inspired by https://github.com/terraform-providers/terraform-provider-kubernetes/issues/38#issuecomment-318581203
        volume {
          name = kubernetes_service_account.flux[0].default_secret_name

          secret {
            secret_name = kubernetes_service_account.flux[0].default_secret_name
          }
        }

        volume {
          name = "docker-creds"

          secret {
            secret_name  = kubernetes_secret.docker-registry-creds[0].metadata[0].name # "docker-image-registry"
            default_mode = 256
          }
        }

        container {
          name              = "flux"
          image             = "quay.io/weaveworks/flux:1.8.2"
          image_pull_policy = "IfNotPresent"

          resources {
            requests {
              cpu    = "50m"
              memory = "64Mi"
            }
          }

          port {
            container_port = 3030
          }

          volume_mount {
            name       = "git-key"
            mount_path = "/etc/fluxd/ssh"
            read_only  = true
          }

          volume_mount {
            name       = "git-keygen"
            mount_path = "/var/fluxd/keygen"
          }

          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = kubernetes_service_account.flux[0].default_secret_name
            read_only  = true
          }

          volume_mount {
            name       = "docker-creds"
            mount_path = "/docker-creds" #"/docker-creds/config.json" #"/etc/fluxd/ssh"
            read_only  = true
          }

          # args = "${var.container_args}"
          args = [
            "--ssh-keygen-dir=/var/fluxd/keygen",
            "--git-url=${var.git_url}",
            "--git-branch=${var.git_branch}",
            "--git-label=${var.git_label}",
            "--listen-metrics=:3031",
            "--docker-config=/docker-creds/.dockerconfigjson",
          ] # "--docker-config=/docker-creds/config.json"            
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.flux_namespace]
  provider   = kubernetes
}

