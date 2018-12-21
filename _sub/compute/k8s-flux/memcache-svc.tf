resource "kubernetes_service" "flux-memcached" {
  metadata {
    name = "memcached"
    namespace = "${var.namespace}"
  }

  spec {
    # The memcache client uses DNS to get a list of memcached servers and then  # uses a consistent hash of the key to determine which server to pick.      
    cluster_ip = "None"

    port {
      name = "memcached"
      port = 11211
    }

    selector {
      name = "memcached"
    }
  }
  provider = "kubernetes"
}
