resource "helm_release" "grafana_agent" {
  name             = "grafana-k8s-monitoring"
  repository       = var.helm_repo_url
  chart            = "k8s-monitoring"
  version          = var.chart_version
  namespace        = var.namespace
  atomic           = var.atomic
  timeout          = var.timeout
  create_namespace = var.create_namespace

  values = [
    templatefile("${path.module}/values/values.yaml", {
      cluster_name                           = var.cluster_name,
      api_token                              = var.api_token,
      prometheus_url                         = var.prometheus_url,
      prometheus_username                    = var.prometheus_username,
      loki_url                               = var.loki_url,
      loki_username                          = var.loki_username,
      tempo_url                              = var.tempo_url,
      tempo_username                         = var.tempo_username,
      traces_enabled                         = var.traces_enabled,
      open_cost_enabled                      = var.open_cost_enabled
      enable_side_by_side                    = var.enable_side_by_side,
      agent_resource_memory_limit            = var.agent_resource_memory_limit,
      agent_resource_memory_request          = var.agent_resource_memory_request,
      tolerations                            = var.tolerations,
      affinity                               = var.affinity,
      agent_replicas                         = var.agent_replicas,
      storage_enabled                        = var.storage_enabled,
      storage_class                          = var.storage_class,
      storage_size                           = var.storage_size,
      prometheus_node_exporter_priorityclass = var.priority_class,
      kube_state_metrics_priorityclass       = var.priority_class,
      affinity                               = var.affinity,
    }),
  ]
}
