locals {
  name      = "confluent-provider"
}

resource "kubernetes_secret" "this" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }

  data = {
    secret = "${var.email}:${var.password}"
  }
}

resource "kubectl_manifest" "this" {
    yaml_body = <<YAML
apiVersion: confluent.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
  name: ${local.name}
spec:
  credentials:
    source: Secret
    secretRef:
      name: ${local.name}
      namespace: ${var.namespace}
      key: secret
YAML
}


resource "github_repository_file" "crossplane_provider_confluent_path" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-config.yaml"
  content    = jsonencode(local.app_config_path)
}

resource "github_repository_file" "crossplane_provider_confluent_init" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/kustomization.yaml"
  content    = jsonencode(local.config_init)
}

resource "github_repository_file" "crossplane_provider_confluent_configmap_environments" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/configmap_environments.yaml"
  content    = jsonencode(local.config_map_confluent_emvironments)
}

resource "github_repository_file" "crossplane_provider_confluent_configmap_clusters" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/configmap_clusters.yaml"
  content    = jsonencode(local.config_map_confluent_clusters)
}


# resource "github_repository_file" "crossplane_provider_confluent_configmaps" {
#   repository = var.repo_name
#   branch     = local.repo_branch
#   file       = "${local.config_repo_path}/configmaps.yaml"
#   content    = local.yaml_body_config_map
# }

