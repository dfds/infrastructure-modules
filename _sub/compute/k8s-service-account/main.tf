resource "kubernetes_service_account" "deploy-user" {
  metadata {
    name      = "deploy-user"
    namespace = "kube-system"
  }

  provider = kubernetes

  depends_on = [var.module_depends_on]
}

resource "kubernetes_cluster_role_binding" "deploy-user" {
  metadata {
    name = "deploy-user"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "deploy-user"
    namespace = "kube-system"
  }

  provider = kubernetes

  depends_on = [var.module_depends_on]
}

data "external" "get-token" {
  program = ["sh", "${path.module}/get-token.sh"]

  query = {
    cluster_name        = var.cluster_name
    default_secret_name = kubernetes_service_account.deploy-user.default_secret_name
    kubeconfig_path     = var.kubeconfig_path
  }

}