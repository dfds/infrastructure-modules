resource "random_password" "grafana_password" {
  length  = 32
  special = true
}

resource "aws_ssm_parameter" "param_grafana_password" {
  name        = "/eks/${var.cluster_name}/${helm_release.kube_prometheus_stack.name}-grafana-password"
  description = "Password for accessing the Grafana dashboard"
  type        = "SecureString"
  value       = var.grafana_admin_password != "" ? var.grafana_admin_password : random_password.grafana_password.result

  lifecycle {
    ignore_changes = [
      overwrite,
    ]
  }
}

resource "aws_ssm_parameter" "param_grafana_username" {
  name        = "/eks/${var.cluster_name}/${helm_release.kube_prometheus_stack.name}-grafana-username"
  description = "Username for accessing the Grafana dashboard"
  type        = "String"
  value       = "admin"

  lifecycle {
    ignore_changes = [
      overwrite,
    ]
  }
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
      enable_components = var.enable_prom_kube_stack_components
    }),

    templatefile("${path.module}/values/grafana.yaml", {
      grafana_admin_password      = var.grafana_admin_password != "" ? var.grafana_admin_password : random_password.grafana_password.result
      grafana_priorityclass       = var.priority_class
      grafana_ingress_path        = var.grafana_ingress_path
      grafana_host                = var.grafana_host
      grafana_root_url            = "https://%(domain)s${var.grafana_ingress_path}"
      grafana_cloudwatch_role     = var.grafana_iam_role_arn
      grafana_serviceaccount_name = var.grafana_serviceaccount_name
      grafana_storage_enabled     = var.grafana_storage_enabled
      grafana_storage_class       = var.grafana_storage_class
      grafana_storage_size        = var.grafana_storage_size
      grafana_app_id              = try(azuread_application.grafana[0].application_id, "")
      grafana_app_secret          = try(azuread_application_password.grafana[0].value, "")
      grafana_azure_tenant_id     = length(var.grafana_azure_tenant_id) == 36 ? var.grafana_azure_tenant_id : ""
      tolerations                 = var.tolerations,
      affinity                    = var.affinity,
      grafana_slack_webhook       = var.slack_webhook,
      grafana_notifier_name       = var.grafana_notifier_name
      grafana_serve_from_sub_path = var.grafana_serve_from_sub_path
    }),

    templatefile("${path.module}/values/prometheus.yaml", {
      prometheus_priorityclass                            = var.priority_class
      prometheus_storageclass                             = var.prometheus_storageclass
      prometheus_storage_size                             = var.prometheus_storage_size
      prometheus_retention                                = var.prometheus_retention
      prometheus_request_memory                           = var.prometheus_request_memory
      prometheus_request_cpu                              = var.prometheus_request_cpu
      prometheus_limit_memory                             = var.prometheus_limit_memory
      prometheus_limit_cpu                                = var.prometheus_limit_cpu
      query_log_file_enabled                              = var.query_log_file_enabled
      enable_features                                     = var.enable_features
      tolerations                                         = var.tolerations,
      affinity                                            = var.affinity,
      prometheus_confluent_metrics_scrape_enabled         = var.prometheus_confluent_metrics_scrape_enabled,
      prometheus_confluent_metrics_api_key                = var.prometheus_confluent_metrics_api_key,
      prometheus_confluent_metrics_api_secret             = var.prometheus_confluent_metrics_api_secret,
      prometheus_confluent_metrics_scrape_interval        = var.prometheus_confluent_metrics_scrape_interval,
      prometheus_confluent_metrics_scrape_timeout         = var.prometheus_confluent_metrics_scrape_timeout,
      prometheus_confluent_metrics_resource_kafka_id_list = var.prometheus_confluent_metrics_resource_kafka_id_list,
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
      tolerations = var.tolerations,
      affinity    = var.affinity,
    }),

    templatefile("${path.module}/values/node-exporter.yaml", {
      prometheus_node_exporter_priorityclass = var.priority_class
    }),

    templatefile("${path.module}/values/kube-state-metrics.yaml", {
      kube_state_metrics_priorityclass = var.priority_class
      tolerations                      = var.tolerations,
      affinity                         = var.affinity,
    })
  ]
}

resource "github_repository_file" "grafana_config_path" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.cluster_repo_path}/${local.grafana_platform_apps_name}-config.yaml"
  content             = jsonencode(local.grafana_config_path)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "grafana_config_middleware" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.config_repo_path}/middleware.yaml"
  content             = jsonencode(local.grafana_config_middleware)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "grafana_config_ingressroute" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.config_repo_path}/ingressroute.yaml"
  content             = jsonencode(local.grafana_config_ingressroute)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "grafana_config_alert_config" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.config_repo_path}/alert-config.yaml"
  content             = jsonencode(local.grafana_config_alert_config)
  overwrite_on_create = var.overwrite_on_create
}

resource "github_repository_file" "grafana_config_init" {
  repository          = var.repo_name
  branch              = local.repo_branch
  file                = "${local.config_repo_path}/kustomization.yaml"
  content             = jsonencode(local.grafana_config_init)
  overwrite_on_create = var.overwrite_on_create
}

data "azuread_client_config" "current" {}

resource "random_uuid" "admin" {}

resource "random_uuid" "viewer" {}

resource "random_uuid" "editor" {}

resource "azuread_application" "grafana" {
  count           = length(var.grafana_azure_tenant_id) == 36 ? 1 : 0
  display_name    = "Grafana OAuth for ${var.grafana_host}"
  identifier_uris = ["https://${var.grafana_host}"]
  owners          = [data.azuread_client_config.current.object_id]

  web {
    homepage_url  = "https://${var.grafana_host}${var.grafana_ingress_path}"
    redirect_uris = ["https://${var.grafana_host}${var.grafana_ingress_path}/login/azuread", "https://${var.grafana_host}${var.grafana_ingress_path}"]
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Grafana org admin Users"
    display_name         = "Grafana Org Admin"
    enabled              = true
    id                   = random_uuid.admin.result
    value                = "Admin"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Grafana read only Users"
    display_name         = "Grafana Viewer"
    enabled              = true
    id                   = random_uuid.viewer.result
    value                = "Viewer"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Grafana Editor Users"
    display_name         = "Grafana Editor"
    enabled              = true
    id                   = random_uuid.editor.result
    value                = "Editor"
  }
}

resource "azuread_application_password" "grafana" {
  count          = length(var.grafana_azure_tenant_id) == 36 ? 1 : 0
  application_id = "/applications/${azuread_application.grafana[0].object_id}"
}
