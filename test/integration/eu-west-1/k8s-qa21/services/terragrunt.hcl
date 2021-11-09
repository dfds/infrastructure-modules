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


inputs = {

  # --------------------------------------------------
  # EKS
  # --------------------------------------------------

  eks_cluster_name = "qa21"

  # --------------------------------------------------
  # Traefik
  # --------------------------------------------------

  traefik_alb_auth_deploy = true # triggers Azure App registration
  traefik_alb_anon_deploy = true
  # traefik_alb_auth_core_alias = ["qa-alias1.dfds.cloud", "qa-alias2.dfds.cloud"]
  traefik_alb_auth_core_alias = []


  # --------------------------------------------------
  # Traefik v2
  # --------------------------------------------------
  traefikv2_test_alb_deploy       = true
  traefik_flux_helm_chart_version = "10.3.2"
  traefik_flux_github_owner       = "dfds"
  traefik_flux_repo_name          = "platform-manifests-qa"
  traefik_flux_repo_branch        = "main"

  # --------------------------------------------------
  # Blaster
  # Requires: KIAM
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

  # --------------------------------------------------
  # AWS EBS CSI Driver
  # --------------------------------------------------

  ebs_csi_driver_chart_version = "0.7.1"


  # --------------------------------------------------
  # KIAM
  # --------------------------------------------------


  # --------------------------------------------------
  # Kube-prometheus-stack
  # --------------------------------------------------

  monitoring_kube_prometheus_stack_deploy                  = true
  monitoring_kube_prometheus_stack_chart_version           = "19.0.1"
  monitoring_kube_prometheus_stack_target_namespaces       = "kube-system|monitoring"
  monitoring_kube_prometheus_stack_prometheus_storage_size = "5Gi"
  monitoring_kube_prometheus_stack_prometheus_storageclass = "gp2"
  monitoring_kube_prometheus_stack_prometheus_retention    = "1d"
  monitoring_kube_prometheus_stack_slack_webhook           = "https://dummy.slack.webhook"
  monitoring_kube_prometheus_stack_slack_channel           = "#hellman-alerting"


  # --------------------------------------------------
  # Goldpinger
  # --------------------------------------------------

  monitoring_goldpinger_deploy = true

  # --------------------------------------------------
  # Crossplane
  # --------------------------------------------------

  crossplane_deploy        = true
  crossplane_chart_version = "1.4.0"
  crossplane_providers     = ["crossplane/provider-aws:v0.19.0"]
  crossplane_admin_service_accounts = [
    {
      serviceaccount = "default"
      namespace      = "kube-system"
    }
  ]

  # --------------------------------------------------
  # Atlantis
  # --------------------------------------------------

  atlantis_deploy        = true
  atlantis_ingress       = "atlantis.qa21-alias1.dfds.cloud"
  atlantis_image_tag     = "0.0.7"
  atlantis_storage_class = "gp2"

  atlantis_github_username     = "devex-sa"
  atlantis_github_repositories = ["dfds/qa-dummy-atlantis"]
  atlantis_github_owner        = "dfds"
  atlantis_webhook_events      = ["issue_comment", "pull_request", "pull_request_review", "push"]
  atlantis_chart_version       = "3.12.10"

  atlantis_flux_repo_name     = "platform-manifests-qa"
  atlantis_flux_repo_owner    = "dfds"
  atlantis_flux_repo_branch   = "main"

  # --------------------------------------------------
  # Blackbox Exporter
  # --------------------------------------------------

  blackbox_exporter_deploy              = "true"
  blackbox_exporter_helm_chart_version  = "5.3.1"
  blackbox_exporter_github_owner        = "dfds"
  blackbox_exporter_repo_name           = "platform-manifests-qa"
  blackbox_exporter_repo_branch         = "main"
  blackbox_exporter_monitoring_targets  = [
    {
      "name"    = "example"
      "url"     = "https://example.com/"
      "module"  = "http_2xx"
    }
  ]

}
