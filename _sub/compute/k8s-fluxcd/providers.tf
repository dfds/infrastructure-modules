provider "flux" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
  git = {
    url = "ssh://git@github.com/${data.github_repository.main.full_name}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.main.private_key_pem
    }
  }
}
