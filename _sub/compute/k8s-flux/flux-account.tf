resource "kubernetes_service_account" "flux" {
  metadata {
    name = "flux"
    namespace = "${var.namespace}"
    labels{
        name = "flux" 
    }
  }
  depends_on = ["kubernetes_namespace.flux_namespace"]
  provider = "kubernetes"
}

resource "kubernetes_cluster_role_binding" "flux" {
    metadata {
        name = "flux"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
        api_group = ""
        kind = "ServiceAccount"
        name = "flux"
        namespace = "${var.namespace}"
    }
    depends_on = ["kubernetes_namespace.flux_namespace"]
    provider = "kubernetes"
}