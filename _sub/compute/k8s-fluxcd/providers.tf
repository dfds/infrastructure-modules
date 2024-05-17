provider "flux" {
  kubernetes = {
    host                   = var.endpoint
    token                  = var.token
    cluster_ca_certificate = var.cluster_ca_certificate
  }
  git = {
    url = "ssh://git@github.com/${data.github_repository.main.full_name}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.main.private_key_pem
    }
  }
}
