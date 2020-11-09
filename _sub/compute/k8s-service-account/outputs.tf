output "deploy_user_config" {
  value = data.template_file.kubeconfig_token.rendered
}

