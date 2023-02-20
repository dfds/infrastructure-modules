output "deploy_user_config" {
  value = templatefile(
    "${path.module}/kubeconfig-token.yaml",
    {
      cluster_name = var.cluster_name
      endpoint     = var.eks_endpoint
      ca           = var.eks_certificate_authority
      token        = data.kubernetes_secret.deploy-token.data.token
    }
  )
}

