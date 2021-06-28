resource "github_repository_file" "traefik_kustomization" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.base_repo_path}/kustomization.yaml"
  content    = jsonencode(local.kustomization)
}

resource "github_repository_file" "traefik_patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.base_repo_path}/patch.yaml"
  content    = jsonencode(local.patch)
}
