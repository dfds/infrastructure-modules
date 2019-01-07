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
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
        api_group = ""
        kind = "ServiceAccount"
        name = "tiller"
        namespace = "kube-system"
    }
}
resource "null_resource" "init_helm" {

  provisioner "local-exec" {
        command = "helm init --kubeconfig ${pathexpand("~/.kube/config_${var.cluster_name}")} --skip-refresh --upgrade --service-account tiller"
    }
  
}