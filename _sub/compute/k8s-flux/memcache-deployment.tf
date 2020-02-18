resource "kubernetes_deployment" "flux-memcached" {
  count = var.deploy ? 1 : 0

  metadata {
    name      = "memcached"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "memcached"
      }
    }

    template {
      metadata {
        labels = {
          name = "memcached"
        }
      }

      spec {
        container {
          name              = "memcached"
          image             = "memcached:1.4.25"
          image_pull_policy = "IfNotPresent"
          args              = ["-m 64", "-p 11211"]

          # Maximum memory to use, in megabytes. 64MB is default.
          # Default port, but being explicit is nice.
          # -vv    add it to get logs of each request and response.
          port {
            name           = "clients"
            container_port = 11211
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.flux_namespace]
  provider   = kubernetes
}

