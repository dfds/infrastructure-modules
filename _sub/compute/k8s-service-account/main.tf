resource "kubernetes_service_account" "deploy-user" {
  metadata {
    name      = "deploy-user"
    namespace = "kube-system"
  }

  automount_service_account_token = false

  provider = kubernetes
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
}

resource "kubernetes_secret_v1" "deploy-token" {
  metadata {
    generate_name = "${kubernetes_service_account.deploy-user.metadata[0].name}-token-"
    namespace     = kubernetes_service_account.deploy-user.metadata[0].namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.deploy-user.metadata[0].name
    }
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}
