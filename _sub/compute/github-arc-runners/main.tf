# --------------------------------------------------
# Create YAML files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "github_arc_runners_helm" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content             = local.app_helm_path
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "github_arc_runners_helm_install" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/kustomization.yaml"
  content             = local.helm_install
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "github_arc_runners_helm_patch" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/patch.yaml"
  content             = local.helm_patch
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "github_arc_runners_serviceaccount" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/serviceaccount.yaml"
  content             = local.serviceaccount
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "github_arc_runners_role" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/role.yaml"
  content             = local.role
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "github_arc_runners_rolebinding" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/rolebinding.yaml"
  content             = local.rolebinding
  overwrite_on_create = var.overwrite_on_create
}