resource "github_repository_file" "grafana_agent_helm" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.app_install_name}-helm.yaml"
  content = templatefile("${path.module}/values/app-config.yaml", {
    app_install_name = local.app_install_name
    helm_repo_path   = local.helm_repo_path
    prune            = var.prune
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "grafana_agent_helm_install" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/kustomization.yaml"
  content = templatefile("${path.module}/values/kustomization.yaml", {
    gitops_apps_repo_url    = var.gitops_apps_repo_url
    deploy_name             = var.deploy_name
    gitops_apps_repo_branch = var.gitops_apps_repo_branch
  })
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "grafana_agent_helm_patch" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.helm_repo_path}/patch.yaml"
  content = templatefile("${path.module}/values/patch.yaml", {
    namespace                              = var.namespace
    helm_chart_version                     = var.chart_version
    cluster_name                           = var.cluster_name
    storage_enabled                        = var.storage_enabled
    agent_resource_memory_request          = var.agent_resource_memory_request
    agent_resource_memory_limit            = var.agent_resource_memory_limit
    tolerations                            = var.tolerations
    affinity                               = var.affinity
    agent_replicas                         = var.agent_replicas
    storage_class                          = var.storage_class
    storage_size                           = var.storage_size
    prometheus_url                         = var.prometheus_url
    prometheus_username                    = var.prometheus_username
    api_token                              = var.api_token
    loki_url                               = var.loki_url
    loki_username                          = var.loki_username
    tempo_url                              = var.tempo_url
    tempo_username                         = var.tempo_username
    traces_enabled                         = var.traces_enabled
    open_cost_enabled                      = var.open_cost_enabled
    kube_state_metrics_priorityclass       = var.priority_class
    prometheus_node_exporter_priorityclass = var.priority_class
  })
  overwrite_on_create = var.overwrite_on_create
}
