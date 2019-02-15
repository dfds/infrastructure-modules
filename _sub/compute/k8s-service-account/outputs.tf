output "deploy_user_config" {
  value = "${data.external.get-token.result["kubeconfig_json"]}"
}
