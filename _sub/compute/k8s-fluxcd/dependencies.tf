# --------------------------------------------------
# Namespace
# --------------------------------------------------

locals {
  namespace = "flux-system"
}


# --------------------------------------------------
# Bootstrap Kubernetes manifests
# --------------------------------------------------

data "flux_install" "main" {
  target_path = var.repo_path
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.main.content
}

data "flux_sync" "main" {
  target_path = var.repo_path
  url         = "ssh://git@github.com/${var.github_owner}/${var.repo_name}.git"
  branch      = var.repo_branch
  namespace   = local.namespace
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}


# --------------------------------------------------
# Github
# --------------------------------------------------

locals {
  known_hosts = "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="
}

data "github_repository" "main" {
  name = var.repo_name
}