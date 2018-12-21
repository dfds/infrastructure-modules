resource "kubernetes_deployment" "flux" {
  metadata {
    name = "flux"
    namespace = "${var.namespace}"
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        name = "flux"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        annotations {
          prometheus.io.port = "3031" # tell prometheus to scrape /metrics endpoint's port.
        }

        labels {
          name = "flux"
        }
      }

      spec {
        service_account_name = "${kubernetes_service_account.flux.metadata.0.name}"

        volume {
          name = "git-key"

          secret {
            secret_name  = "flux-git-deploy"
            default_mode = 0400
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
          name = "${kubernetes_service_account.flux.default_secret_name}"

          secret {
            secret_name = "${kubernetes_service_account.flux.default_secret_name}"
          }
        }

        container {
          name              = "flux"
          image             = "quay.io/weaveworks/flux:1.8.1"
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
            name       = "${kubernetes_service_account.flux.default_secret_name}"
            read_only  = true
          }

          # args = "${var.flux_container_args}"
          args = [
            "--ssh-keygen-dir=/var/fluxd/keygen",
            "--git-url=${var.config_git_repo_url}",
            "--git-branch=${var.config_git_repo_branch}",
            "--listen-metrics=:3031"
          ]
        }
      }
    }
  }
  provider = "kubernetes"
}
