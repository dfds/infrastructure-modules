resource "kubernetes_service_account" "deploy-user" {
  metadata {
    name      = "deploy-user"
    namespace = "kube-system"
  }

  provider = "kubernetes"
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

  provider = "kubernetes"
}

data "external" "get-token" {
  program = ["sh", "${path.module}/get-token.sh"]
  query = {
    cluster_name = "${var.cluster_name}"
    default_secret_name = "${kubernetes_service_account.deploy-user.default_secret_name}"
  }
}

resource "aws_ssm_parameter" "kubeconfig" {
  name        = "/eks/${var.cluster_name}/deploy-user"
  description = "The initial config file for eks ${var.cluster_name}"
  type        = "SecureString"
  value       = "${data.external.get-token.result["kubeconfig_json"]}"
}