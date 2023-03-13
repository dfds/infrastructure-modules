# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../..//compute/k8s-services"
}

# Include all settings from the root terraform.tfvars file
include {
  path = find_in_parent_folders()
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

  eks_is_sandbox   = true
  eks_cluster_name = "qa"

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

  traefik_flux_github_owner     = "dfds"
  traefik_flux_repo_name          = "platform-manifests-qa"
  traefik_flux_repo_branch      = "main"

  # Blue variant
  traefik_blue_variant_flux_deploy = true
  traefik_blue_variant_flux_dashboard_deploy = true
  traefik_blue_variant_flux_helm_chart_version = "20.8.0"
  traefik_blue_variant_flux_additional_args = [
    "--metrics.prometheus",
    "--providers.kubernetescrd.allowCrossNamespace=true"
  ]
  traefik_blue_variant_flux_weight = 1

  # Green variant
  traefik_green_variant_flux_deploy = false
  traefik_green_variant_flux_dashboard_deploy = false
  traefik_green_variant_flux_helm_chart_version = "20.8.0"
  traefik_green_variant_flux_additional_args = [
    "--metrics.prometheus",
    "--providers.kubernetescrd.allowCrossNamespace=true"
  ]
  traefik_green_variant_flux_weight = 0



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
  # Platform Flux CD
  # --------------------------------------------------

  platform_fluxcd_deploy       = true
  platform_fluxcd_repo_name    = "platform-manifests-qa"
  platform_fluxcd_github_owner = "dfds"
  platform_fluxcd_release_tag  = "v0.38.2"

  # --------------------------------------------------
  # Monitoring
  # --------------------------------------------------

  monitoring_tolerations = [
    {
      key      = "monitoring.dfds",
      operator = "Exists",
      effect   = "NoSchedule",
    }
  ]
  monitoring_affinity = [
    {
      key      = "dedicated",
      operator = "In",
      values   = ["monitoring"],
    }
  ]

  # --------------------------------------------------
  # Kube-prometheus-stack
  # --------------------------------------------------

  monitoring_kube_prometheus_stack_deploy                    = true
  monitoring_kube_prometheus_stack_chart_version             = "44.3.0"
  monitoring_kube_prometheus_stack_target_namespaces         = "kube-system|monitoring"
  monitoring_kube_prometheus_stack_prometheus_storage_size   = "5Gi"
  monitoring_kube_prometheus_stack_prometheus_storageclass   = "gp2"
  monitoring_kube_prometheus_stack_prometheus_retention      = "1d"
  monitoring_kube_prometheus_stack_slack_webhook             = "https://dummy.slack.webhook"
  monitoring_kube_prometheus_stack_slack_channel             = "#hellman-alerting"
  monitoring_kube_prometheus_stack_github_owner              = "dfds"
  monitoring_kube_prometheus_stack_repo_name                 = "platform-manifests-qa"
  monitoring_kube_prometheus_stack_repo_branch               = "main"
  monitoring_kube_prometheus_stack_prometheus_request_memory = "500Mi"
  monitoring_kube_prometheus_stack_prometheus_request_cpu    = "500m"
  monitoring_kube_prometheus_stack_prometheus_limit_memory   = "2Gi"
  monitoring_kube_prometheus_stack_prometheus_limit_cpu      = "1000m"
  monitoring_kube_prometheus_stack_grafana_storage_enabled   = true
  monitoring_kube_prometheus_stack_grafana_storage_size      = "5Gi"
  monitoring_kube_prometheus_stack_grafana_storageclass      = "gp2"
  # monitoring_kube_prometheus_stack_azure_tenant_id is set as ARM_TENANT_ID in
  # Azure DevOps Pipeline Library "Infrastructure-Modules QA" in and mapped in the
  # Azure DevOps pipeline file as TF_VAR_monitoring_kube_prometheus_stack_azure_tenant_id

  # --------------------------------------------------
  # Metrics-Server
  # --------------------------------------------------

  monitoring_metrics_server_chart_version = "3.8.2"


  # --------------------------------------------------
  # Goldpinger
  # --------------------------------------------------

  monitoring_goldpinger_deploy = true

  # --------------------------------------------------
  # Crossplane
  # --------------------------------------------------

  crossplane_deploy        = false
  crossplane_chart_version = "1.6.3-up.1"
  # Do not configure Confluent provider in QA
  crossplane_providers = ["crossplane/provider-aws:v0.26.0", "crossplane/provider-kubernetes:v0.3.0"]
  crossplane_admin_service_accounts = [
    {
      serviceaccount = "default"
      namespace      = "kube-system"
    }
  ]
  eks_openid_connect_provider_url = dependency.cluster.outputs.eks_openid_connect_provider_url

  crossplane_cfg_pkg_deploy       = false
  crossplane_cfg_pkg_docker_image = "dfdsdk/dfds-infra:v0.0.1-alpha.28"

  crossplane_operator_deploy             = false
  crossplane_operator_helm_chart_version = "0.1.5"

  # --------------------------------------------------
  # Atlantis
  # --------------------------------------------------

  atlantis_deploy        = true
  atlantis_ingress       = "atlantis.qa-alias1.dfds.cloud"
  atlantis_image_tag     = "0.0.23"
  atlantis_storage_class = "gp2"

  atlantis_github_username     = "devex-sa"
  atlantis_github_repositories = ["dfds/qa-dummy-atlantis"]
  atlantis_github_owner        = "dfds"
  atlantis_webhook_events      = ["issue_comment", "pull_request", "pull_request_review", "push"]
  atlantis_chart_version       = "4.1.2"

  atlantis_flux_repo_name   = "platform-manifests-qa"
  atlantis_flux_repo_owner  = "dfds"
  atlantis_flux_repo_branch = "main"

  # --------------------------------------------------
  # Blackbox Exporter
  # --------------------------------------------------

  blackbox_exporter_deploy       = "true"
  blackbox_exporter_github_owner = "dfds"
  blackbox_exporter_repo_name    = "platform-manifests-qa"
  blackbox_exporter_repo_branch  = "main"
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

  helm_exporter_deploy              = "true"
  helm_exporter_helm_chart_version  = "1.2.4"
  helm_exporter_github_owner        = "dfds"
  helm_exporter_repo_name           = "platform-manifests-qa"
  helm_exporter_repo_branch         = "main"
  helm_exporter_target_namespaces   = "fluentd,flux-system,monitoring,traefik-blue-variant"
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

  podinfo_flux_deploy = true

  # --------------------------------------------------
  # fluent-cloudwatch
  # --------------------------------------------------

  fluentd_cloudwatch_flux_deploy = true

  # --------------------------------------------------
  # Velero - requires that s3-bucket-velero module
  # is already applied through Terragrunt.
  # --------------------------------------------------

  velero_flux_deploy            = true
  velero_flux_role_arn          = "arn:aws:iam::266901158286:role/VeleroBackup"
  velero_flux_bucket_name       = "dfds-velero-qa"
  velero_plugin_for_aws_version = "v1.4.1"
  velero_plugin_for_csi_version = "v0.2.0"

  # --------------------------------------------------
  # kyverno
  # --------------------------------------------------

  kyverno_deploy        = false
  kyverno_chart_version = "v2.5.2"

}
