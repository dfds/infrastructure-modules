# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../..//compute/k8s-services"
}

# Include all settings from the root terraform.tfvars file
include {
  path = "${find_in_parent_folders()}"
}

dependencies {
  paths = ["../cluster"]
}


inputs = {

  # --------------------------------------------------
  # EKS
  # --------------------------------------------------

  eks_cluster_name = "qa19"

  # --------------------------------------------------
  # Traefik
  # --------------------------------------------------

  traefik_alb_auth_deploy = true # triggers Azure App registration
  traefik_alb_anon_deploy = true
  # traefik_alb_auth_core_alias = ["qa-alias1.dfds.cloud", "qa-alias2.dfds.cloud"]
  traefik_alb_auth_core_alias = []

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
  # Traefik Okta
  # --------------------------------------------------

  traefik_okta_deploy         = true
  traefik_okta_version        = "2.2"
  traefik_alb_okta_deploy     = true
  traefik_alb_okta_core_alias = []

  # --------------------------------------------------
  # KIAM
  # --------------------------------------------------


  # --------------------------------------------------
  # Kube-prometheus-stack
  # --------------------------------------------------

  monitoring_kube_prometheus_stack_deploy                  = true
  monitoring_kube_prometheus_stack_chart_version           = "10.1.0"
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
  crossplane_chart_version = "1.0.0"
  crossplane_providers     = ["crossplane/provider-aws:v0.16.0"]
  crossplane_admin_service_accounts = [
    {
      serviceaccount = "default"
      namespace = "kube-system"
    }
  ]

  # --------------------------------------------------
  # Atlantis
  # --------------------------------------------------

  atlantis_deploy        = true
  atlantis_ingress       = "atlantis.qa19-alias1.dfds.cloud"
  atlantis_image_tag     = "0.0.3"
  atlantis_storage_class = "gp2"

  atlantis_github_username     = "devex-sa"
  atlantis_github_repositories = ["dfds/qa-dummy-atlantis"]
  atlantis_github_organization = "dfds"
  atlantis_webhook_events      = ["issue_comment", "pull_request", "pull_request_review", "push"]
  atlantis_chart_version       = "3.12.10"

}
