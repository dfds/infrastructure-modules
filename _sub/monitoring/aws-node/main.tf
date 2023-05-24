# --------------------------------------------------
# Scrape Prometheus metrics for aws-node Daemonset
# --------------------------------------------------

locals {
  svc_name = var.svc_name == null ? var.app_name : var.svc_name
}

data "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = local.svc_name
    namespace = data.kubernetes_namespace.this.metadata[0].name
    labels = {
      k8s-app                = var.app_name
      scrape-service-metrics = "true"
    }
  }
  spec {
    type                    = var.svc_type
    internal_traffic_policy = var.internal_traffic_policy
    ip_families             = var.ip_families
    ip_family_policy        = var.ip_family_policy
    session_affinity        = var.session_affinity
    port {
      name        = var.port_name
      protocol    = var.protocol
      port        = var.port
      target_port = var.target_port
    }
    selector = {
      k8s-app = var.app_name
    }
  }
}
