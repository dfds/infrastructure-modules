# --------------------------------------------------
# Create YAML files to be picked up by Flux CD
# --------------------------------------------------
resource "github_repository_file" "kafka-exporter_helm" {
  count               = length(var.kafka_clusters) > 0 ? 1 : 0
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content             = local.app_helm_path
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "kafka-exporter_helm_install" {
  count               = length(var.kafka_clusters) > 0 ? 1 : 0
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/kustomization.yaml"
  content             = local.helm_install
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "kafka-exporter_helm_manifest" {
  for_each = local.clusters
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.helm_repo_path}/manifest-${each.value.original.id}.yaml"
  content             = each.value.manifest
  overwrite_on_create = var.overwrite_on_create
}
