locals {
  kustomization_path = "./platform-apps/${var.cluster_name}/kafka-exporter"
}

resource "github_repository_file" "apps" {
  for_each   = var.kafka_clusters
  repository = var.repo_name
  branch     = var.repo_branch
  file       = "clusters/${var.cluster_name}/platform-apps-kafka-exporter-${each.value.id}.yaml"
  content = templatefile("${path.module}/apps.yaml", {
    path                = local.kustomization_path
    cluster_id          = each.value.id
    cluster_environment = each.value.environment
  })
  overwrite_on_create = true
}

resource "github_repository_file" "kustomization" {
  count      = length(var.kafka_clusters) > 0 ? 1 : 0
  repository = var.repo_name
  branch     = var.repo_branch
  file       = "${local.kustomization_path}/kustomization.yaml"
  content = templatefile("${path.module}/kustomization.yaml", {
    apps_repo_url = var.apps_repo_url
    apps_repo_ref = var.apps_repo_ref
  })
  overwrite_on_create = true
}
