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

  eks_cluster_name          = "qa"
  eks_is_sandbox            = true
  enable_inactivity_cleanup = false
  use_worker_nat_gateway    = true

  # --------------------------------------------------
  # Traefik v2
  # --------------------------------------------------

  # Blue variant
  traefik_blue_variant_deploy             = true
  traefik_blue_variant_dashboard_deploy   = true
  traefik_blue_variant_helm_chart_version = "37.0.0"
  traefik_blue_variant_additional_args = [
    "--metrics.prometheus",
    "--providers.kubernetescrd.allowCrossNamespace=true",
  ]
  traefik_blue_variant_weight = 1

  # Green variant
  traefik_green_variant_deploy             = false
  traefik_green_variant_dashboard_deploy   = false
  traefik_green_variant_helm_chart_version = "37.0.0"
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

  slack_webhook_url = "https://dummy.slack.webhook"

  # --------------------------------------------------
  # Flux CD
  # --------------------------------------------------

  fluxcd_apps_repo_branch           = "qa"
  fluxcd_bootstrap_repo_branch      = "main"
  fluxcd_bootstrap_repo_name        = "platform-manifests-qa"
  fluxcd_bootstrap_repo_owner       = "dfds"
  fluxcd_version                    = "v2.6.4"


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
  # Atlantis
  # --------------------------------------------------

  atlantis_chart_version              = "5.17.2"
  atlantis_github_repositories        = ["dfds/qa-dummy-atlantis"]
  atlantis_github_username            = "devex-sa"
  atlantis_resources_requests_cpu     = "10m"
  atlantis_resources_requests_memory  = "512Mi"

  # --------------------------------------------------
  # Velero - requires that s3-bucket-velero module
  # is already applied through Terragrunt.
  # --------------------------------------------------

  velero_deploy                               = true
  velero_bucket_arn                           = "arn:aws:s3:::dfds-velero-qa"
  velero_helm_chart_version                   = "10.0.4"
  velero_plugin_for_aws_version               = "v1.12.1"
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
  external_secrets_helm_chart_version = "0.19.2"

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

  # --------------------------------------------------
  # External DNS
  # --------------------------------------------------
  external_dns_deploy                     = true
  external_dns_helm_chart_version         = "1.19.0"
  external_dns_domain_filters             = ["test.qa.dfds"]
  external_dns_is_debug_mode              = true
}
