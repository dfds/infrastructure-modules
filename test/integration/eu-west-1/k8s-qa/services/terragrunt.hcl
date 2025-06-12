# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../..//compute/k8s-services"

  before_hook "custom_hook_01" {
    commands = ["apply"]
    execute  = ["${get_parent_terragrunt_dir()}/hooks/custom_hook_01.sh", "${get_parent_terragrunt_dir()}"]
  }
}

# Include all settings from the root terraform.tfvars file
include {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../cluster"]
}

dependency "cluster" {
  config_path = "../cluster"
}


inputs = {

  # --------------------------------------------------
  # EKS
  # --------------------------------------------------

  eks_is_sandbox            = true
  eks_cluster_name          = "qa"
  enable_inactivity_cleanup = false
  use_worker_nat_gateway    = true

  # --------------------------------------------------
  # Load Balancers in front of Traefik
  # --------------------------------------------------

  traefik_alb_auth_deploy = true # triggers Azure App registration
  traefik_alb_anon_deploy = true
  # traefik_alb_auth_core_alias = ["qa-alias1.dfds.cloud", "qa-alias2.dfds.cloud"]
  traefik_alb_auth_core_alias = []


  # --------------------------------------------------
  # Traefik v2
  # --------------------------------------------------

  traefikv2_test_alb_deploy = true

  # Blue variant
  traefik_blue_variant_deploy             = true
  traefik_blue_variant_dashboard_deploy   = true
  traefik_blue_variant_helm_chart_version = "35.2.0"
  traefik_blue_variant_additional_args = [
    "--metrics.prometheus",
    "--providers.kubernetescrd.allowCrossNamespace=true",
  ]
  traefik_blue_variant_weight = 1

  # Green variant
  traefik_green_variant_deploy             = false
  traefik_green_variant_dashboard_deploy   = false
  traefik_green_variant_helm_chart_version = "35.2.0"
  traefik_green_variant_additional_args = [
    "--metrics.prometheus",
    "--providers.kubernetescrd.allowCrossNamespace=true",
  ]
  traefik_green_variant_weight = 0



  # --------------------------------------------------
  # Blaster
  # --------------------------------------------------

  blaster_deploy           = true
  blaster_configmap_bucket = ""

  # --------------------------------------------------
  # Cloudwatch alarms and alarm notifier (Slack)
  # --------------------------------------------------

  alarm_notifier_deploy                      = true
  slack_webhook_url                          = "https://dummy.slack.webhook"
  cloudwatch_alarm_alb_targets_health_deploy = true
  cloudwatch_alarm_alb_5XX_deploy            = true

  # --------------------------------------------------
  # Flux CD
  # --------------------------------------------------

  fluxcd_version                    = "v2.5.1"

  fluxcd_bootstrap_repo_name        = "platform-manifests-qa"
  fluxcd_bootstrap_repo_branch      = "main"
  fluxcd_bootstrap_repo_owner       = "dfds"

  fluxcd_apps_repo_name             = "platform-apps"
  fluxcd_apps_repo_branch           = "qa"
  fluxcd_apps_repo_owner            = "dfds"


  # --------------------------------------------------
  # Monitoring
  # --------------------------------------------------

  monitoring_tolerations = [
    {
      key      = "observability.dfds",
      operator = "Exists",
      effect   = "NoSchedule",
    }
  ]
  monitoring_affinity = [
    {
      key      = "dedicated",
      operator = "In",
      values   = ["observability"],
    }
  ]

  # --------------------------------------------------
  # Kube-prometheus-stack
  # --------------------------------------------------

  monitoring_kube_prometheus_stack_deploy                            = true
  monitoring_kube_prometheus_stack_chart_version                     = "55.4.1"
  monitoring_kube_prometheus_stack_target_namespaces                 = "kube-system|monitoring"
  monitoring_kube_prometheus_stack_prometheus_storage_size           = "5Gi"
  monitoring_kube_prometheus_stack_prometheus_storageclass           = "gp2"
  monitoring_kube_prometheus_stack_prometheus_retention              = "1d"
  monitoring_kube_prometheus_stack_slack_webhook                     = ""
  monitoring_kube_prometheus_stack_slack_channel                     = "#hellman-alerting"
  monitoring_kube_prometheus_stack_prometheus_request_memory         = "500Mi"
  monitoring_kube_prometheus_stack_prometheus_request_cpu            = "500m"
  monitoring_kube_prometheus_stack_prometheus_limit_memory           = "2Gi"
  monitoring_kube_prometheus_stack_prometheus_limit_cpu              = "1000m"
  monitoring_kube_prometheus_stack_grafana_enabled                   = false
  monitoring_kube_prometheus_stack_grafana_storage_enabled           = false
  monitoring_kube_prometheus_stack_grafana_storage_size              = "5Gi"
  monitoring_kube_prometheus_stack_grafana_storageclass              = "gp2"
  monitoring_kube_prometheus_stack_prometheus_query_log_file_enabled = true
  monitoring_kube_prometheus_stack_prometheus_enable_features        = ["memory-snapshot-on-shutdown"]
  monitoring_kube_prometheus_stack_prometheus_confluent_metrics_scrape_enabled = true
  monitoring_kube_prometheus_stack_prometheus_confluent_metrics_api_key = "fake"      # pragma: allowlist secret
  monitoring_kube_prometheus_stack_prometheus_confluent_metrics_api_secret = "fake"   # pragma: allowlist secret


  # --------------------------------------------------
  # Goldpinger
  # --------------------------------------------------

  goldpinger_deploy = true

  # --------------------------------------------------
  # Atlantis
  # --------------------------------------------------

  atlantis_deploy       = true
  atlantis_ingress      = "atlantis.qa.qa.dfds.cloud"
  atlantis_data_storage = "1Gi"

  atlantis_resources_requests_cpu    = "10m"
  atlantis_resources_limits_cpu      = "10m"
  atlantis_resources_requests_memory = "512Mi"

  atlantis_github_username     = "devex-sa"
  atlantis_github_repositories = ["dfds/qa-dummy-atlantis"]
  atlantis_github_owner        = "dfds"
  atlantis_webhook_events      = ["issue_comment", "pull_request", "pull_request_review", "push"]
  atlantis_chart_version       = "5.17.2"
  atlantis_environment         = "qa"
  atlantis_image_tag           = "2.1.0"
  atlantis_add_secret_volumes  = true

  # --------------------------------------------------
  # Blackbox Exporter
  # --------------------------------------------------

  blackbox_exporter_deploy = "true"
  blackbox_exporter_monitoring_targets = [
    {
      "name"   = "example"
      "url"    = "https://example.com/"
      "module" = "http_2xx"
    }
  ]

  # --------------------------------------------------
  # Helm Exporter
  # --------------------------------------------------

  helm_exporter_deploy             = "true"
  helm_exporter_target_namespaces  = "flux-system,monitoring,traefik-blue-variant"
  helm_exporter_target_charts = [
    {
      registry = {
        url = "https://helm.traefik.io/traefik/index.yaml"
      }
      "charts" = [
        "traefik"
      ]
    },
    {
      registry = {
        url = "https://kubernetes-sigs.github.io/metrics-server/index.yaml"
      }
      "charts" = [
        "metrics-server"
      ]
    },
    {
      registry = {
        url = "https://prometheus-community.github.io/helm-charts/index.yaml"
      }
      "charts" = [
        "kube-prometheus-stack"
      ]
    },
    {
      registry = {
        url = "https://shanestarcher.com/helm-charts/index.yaml"
      }
      "charts" = [
        "helm-exporter"
      ]
    }
  ]
  # --------------------------------------------------
  # Podinfo
  # --------------------------------------------------

  podinfo_deploy = true

  # --------------------------------------------------
  # Velero - requires that s3-bucket-velero module
  # is already applied through Terragrunt.
  # --------------------------------------------------

  velero_deploy                               = true
  velero_bucket_arn                           = "arn:aws:s3:::dfds-velero-qa"
  velero_helm_chart_version                   = "9.1.2"
  velero_plugin_for_aws_version               = "v1.12.0"
  velero_excluded_namespace_scoped_resources  = ["secrets"]
  velero_filesystem_backup_enabled            = false
  velero_snapshots_enabled                    = true

  # --------------------------------------------------
  # Grafana Agent for Kubernetes monitoring
  # --------------------------------------------------

  grafana_deploy = true
  grafana_agent_chart_version = "1.4.4"
  grafana_agent_resource_memory_request = "4Gi"
  grafana_agent_resource_memory_limit   = "4Gi"
  grafana_agent_storage_enabled = true
  grafana_agent_storage_size = "10Gi"
  grafana_agent_namespace = "grafana"

  observability_tolerations = [
    {
      key      = "observability.dfds",
      operator = "Exists",
      effect   = "NoSchedule",
    }
  ]
  observability_affinity = [
    {
      key      = "dedicated",
      operator = "In",
      values   = ["observability"],
    }
  ]

  # --------------------------------------------------
  # External Secrets
  # --------------------------------------------------

  external_secrets_deploy = true

  # --------------------------------------------------
  # External Secrets with SSM
  # --------------------------------------------------

  external_secrets_ssm_deploy = true
  external_secrets_ssm_allowed_namespaces = ["atlantis", "flux-system"]

  # --------------------------------------------------
  # Github ARC SS Controller
  # --------------------------------------------------

  github_arc_ss_controller_deploy = true
  github_arc_ss_controller_helm_chart_version = "0.9.3"

  # --------------------------------------------------
  # Apache Druid Operator
  # --------------------------------------------------

  druid_operator_deploy                   = true
  druid_operator_chart_version            = "0.3.7"
  druid_operator_resources_limits_cpu     = "500m"
  druid_operator_resources_limits_memory  = "128Mi"

  # --------------------------------------------------
  # Trivy Operator
  # --------------------------------------------------

  trivy_operator_deploy                   = true

  tenants = [
    {
      namespace = "flux-tenant-test"
      repositories = [
        {
          url = "https://github.com/dfds/flux-tenant-test"
          branch = "main"
        }
      ]
    }
  ]

  fluxcd_tenants = [
    {
      namespace = "flux-tenant-test"
      repositories = [
        {
          url = "https://github.com/dfds/flux-tenant-test"
          branch = "main"
        }
      ]
    }
  ]

  # --------------------------------------------------
  # 1Password Connect
  # --------------------------------------------------
  onepassword-connect_deploy = true
}
