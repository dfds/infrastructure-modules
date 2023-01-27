resource "random_password" "grafana_password" {
  length  = 32
  special = true
}

resource "aws_ssm_parameter" "param_grafana_password" {
  name        = "/eks/${var.cluster_name}/${helm_release.kube_prometheus_stack.name}-grafana-password"
  description = "Password for accessing the Grafana dashboard"
  type        = "SecureString"
  value       = var.grafana_admin_password != "" ? var.grafana_admin_password : random_password.grafana_password.result
  overwrite   = true
}

resource "aws_ssm_parameter" "param_grafana_username" {
  name        = "/eks/${var.cluster_name}/${helm_release.kube_prometheus_stack.name}-grafana-username"
  description = "Username for accessing the Grafana dashboard"
  type        = "String"
  value       = "admin"
  overwrite   = true
}

resource "helm_release" "kube_prometheus_stack" {
  name          = "monitoring"
  chart         = "kube-prometheus-stack"
  repository    = "https://prometheus-community.github.io/helm-charts"
  version       = var.chart_version
  namespace     = var.namespace
  recreate_pods = true
  force_update  = false

  values = [
    templatefile("${path.module}/values/components.yaml", {
    }),

    templatefile("${path.module}/values/grafana.yaml", {
      grafana_admin_password      = var.grafana_admin_password != "" ? var.grafana_admin_password : random_password.grafana_password.result
      grafana_priorityclass       = var.priority_class
      grafana_ingress_path        = var.grafana_ingress_path
      grafana_host                = var.grafana_host
      grafana_root_url            = "https://%(domain)s${var.grafana_ingress_path}"
      grafana_serve_from_sub_path = var.grafana_serve_from_sub_path
      grafana_cloudwatch_role     = var.grafana_iam_role_arn
      grafana_serviceaccount_name = var.grafana_serviceaccount_name
    }),

    length(var.slack_webhook) > 0 ? templatefile("${path.module}/values/grafana-notifiers.yaml", {
      grafana_notifier_name          = var.grafana_notifier_name
      grafana_slack_notifier_channel = var.slack_channel
      grafana_slack_webhook          = var.slack_webhook
    }) : "",

    templatefile("${path.module}/values/prometheus.yaml", {
      prometheus_priorityclass  = var.priority_class
      prometheus_storageclass   = var.prometheus_storageclass
      prometheus_storage_size   = var.prometheus_storage_size
      prometheus_retention      = var.prometheus_retention
      prometheus_request_memory = var.prometheus_request_memory
      prometheus_request_cpu    = var.prometheus_request_cpu
      prometheus_limit_memory   = var.prometheus_limit_memory
      prometheus_limit_cpu      = var.prometheus_limit_cpu
    }),

    length(var.slack_webhook) > 0 ? templatefile("${path.module}/values/alertmanager-slack.yaml", {
      alertmanager_priorityclass = var.priority_class
      alertmanager_slack_channel = var.slack_channel
      alertmanager_slack_webhook = var.slack_webhook
      target_namespaces          = var.target_namespaces
    }) : file("${path.module}/values/alertmanager-disabled.yaml"),

    templatefile("${path.module}/values/rules.yaml", {
      target_namespaces = var.target_namespaces
    }),

    templatefile("${path.module}/values/prometheus-operator.yaml", {
    }),

    templatefile("${path.module}/values/node-exporter.yaml", {
      prometheus_node_exporter_priorityclass = var.priority_class
    }),

    templatefile("${path.module}/values/kube-state-metrics.yaml", {
      kube_state_metrics_priorityclass = var.priority_class
    })
  ]
}

resource "github_repository_file" "grafana_config_path" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.cluster_repo_path}/${local.grafana_platform_apps_name}-config.yaml"
  content    = jsonencode(local.grafana_config_path)
}

resource "github_repository_file" "grafana_config_middleware" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/middleware.yaml"
  content    = jsonencode(local.grafana_config_middleware)
}

resource "github_repository_file" "grafana_config_ingressroute" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/ingressroute.yaml"
  content    = jsonencode(local.grafana_config_ingressroute)
}

resource "github_repository_file" "grafana_config_init" {
  repository = var.repo_name
  branch     = local.repo_branch
  file       = "${local.config_repo_path}/kustomization.yaml"
  content    = jsonencode(local.grafana_config_init)
}
