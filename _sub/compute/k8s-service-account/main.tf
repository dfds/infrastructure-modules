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

data "kubernetes_secret" "deploy-token" {
  metadata {
    name      = kubernetes_service_account.deploy-user.default_secret_name
    namespace = kubernetes_service_account.deploy-user.metadata[0].namespace
  }
}

data "template_file" "kubeconfig_token" {
  template = file("${path.module}/kubeconfig-token.yaml")
  vars = {
    cluster_name = var.cluster_name
    endpoint     = var.eks_endpoint
    ca           = var.eks_certificate_authority
    token        = data.kubernetes_secret.deploy-token.data.token
  }
}
