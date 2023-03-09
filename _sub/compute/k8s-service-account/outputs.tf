output "deploy_user_kubeconfig" {
  value = templatefile(
    "${path.module}/kubeconfig-token.yaml",
    {
      cluster_name = var.cluster_name
      endpoint     = var.eks_endpoint
      ca           = var.eks_certificate_authority
      token        = kubernetes_secret_v1.deploy-token.data.token
    }
  )
}

