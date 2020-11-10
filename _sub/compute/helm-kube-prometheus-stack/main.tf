resource "helm_release" "kube_prometheus_stack" {
  count         = var.deploy ? 1 : 0
  name          = "kube-prometheus-stack"
  chart         = "kube-prometheus-stack"
  repository          = "https://prometheus-community.github.io/helm-charts"
  version       = var.chart_version != null ? var.chart_version : null
  namespace     = var.namespace
  recreate_pods = true
  force_update  = true

  values = [
    templatefile("${path.module}/values/components.yaml", {
      prometheus_node_exporter_priorityclass = var.priority_class
      kube_state_metrics_priorityclass = var.priority_class
    }),
    templatefile("${path.module}/values/grafana.yaml",{
      grafana_admin_password = var.grafana_admin_password
      grafana_priorityclass = var.priority_class
      grafana_ingress_path = var.grafana_ingress_path
      grafana_host = var.grafana_host
      grafana_root_url = "https://%(domain)s${var.grafana_ingress_path}"
      grafana_notifier_name = var.grafana_notifier_name
      grafana_slack_notifier_channel = var.slack_channel
      grafana_slack_webhook = var.slack_webhook
    }),
    templatefile("${path.module}/values/prometheus.yaml",{
      prometheus_priorityclass = var.priority_class
      prometheus_storageclass = var.prometheus_storageclass
      prometheus_storage_size = var.prometheus_storage_size
      prometheus_retention = var.prometheus_retention

    }),
    templatefile("${path.module}/values/alertmanager.yaml",{
      alertmanager_priorityclass = var.priority_class
      alertmanager_slack_channel = var.slack_channel
      alertmanager_slack_webhook = var.slack_webhook
    }),
    templatefile("${path.module}/values/rules.yaml", {
      target_namespaces = var.target_namespaces
    }),
  ]
}
