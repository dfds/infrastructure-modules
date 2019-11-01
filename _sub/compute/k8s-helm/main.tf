# kubectl -n kube-system create sa tiller
resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }

  provider = "kubernetes"
}

resource "kubernetes_cluster_role_binding" "tiller-binding" {
  metadata {
    name = "tiller-cluster-role"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "kube-system"
  }

  depends_on = ["kubernetes_service_account.tiller"]
}

resource "null_resource" "init_helm_and_wait" {
  triggers {
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "helm init --kubeconfig ${var.kubeconfig_path} --skip-refresh --upgrade --service-account tiller"
  }

  depends_on = ["kubernetes_cluster_role_binding.tiller-binding"]
}
