resource "kubernetes_service_account" "flux" {
  metadata {
    name = "flux"
    # namespace = "kube-system"
    labels{
        name = "flux" 
    }
  }
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
}