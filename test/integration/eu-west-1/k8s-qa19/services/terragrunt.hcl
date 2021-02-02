# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::https://github.com/dfds/infrastructure-modules.git//compute/k8s-services"
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

  traefik_deploy      = true
  traefik_version     = "1.7"
  traefik_deploy_name = "traefik"

  traefik_alb_auth_deploy = true # triggers Azure App registration
  traefik_alb_anon_deploy = true
  # traefik_alb_auth_core_alias = ["qa-alias1.dfds.cloud", "qa-alias2.dfds.cloud"]
  traefik_alb_auth_core_alias = []

  traefik_nlb_deploy      = false # needed a.o. for Argo CLI
  traefik_nlb_cidr_blocks = ["0.0.0.0/0"]

  # --------------------------------------------------
  # KIAM
  # --------------------------------------------------

  kiam_deploy = true


  # --------------------------------------------------
  # Blaster
  # Requires: KIAM
  # --------------------------------------------------

  blaster_deploy           = true
  blaster_configmap_bucket = ""

  # --------------------------------------------------
  # Cloudwatch alarms and alarm notifier (Slack)
  # --------------------------------------------------

  alarm_notifier_deploy = true
  slack_webhook_url = "https://dummy.slack.webhook"
  cloudwatch_alarm_alb_targets_health_deploy = true
  cloudwatch_alarm_alb_5XX_deploy = true

  # --------------------------------------------------
  # Platform Flux CD
  # --------------------------------------------------

  platform_fluxcd_deploy       = true
  platform_fluxcd_repo_name    = "platform-manifests-qa"
  platform_fluxcd_github_owner = "dfds"

  # --------------------------------------------------
  # AWS EBS CSI Driver
  # --------------------------------------------------

  ebs_csi_driver_deploy = true
  ebs_csi_driver_chart_version = "0.7.1"

}
