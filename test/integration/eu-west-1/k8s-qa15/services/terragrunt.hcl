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

  eks_cluster_name = "qa15"


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

  # --------------------------------------------------
  # Cloudwatch ALB 500 errors alerts to slack
  # --------------------------------------------------

  cw_alb_alerts_deploy = true
  traefik_alb_slack_hook = "https://dummy.dum/dummy"
  traefik_alb_slack_channel = "dummy"
  traefik_alb_lambda_name = "cw_to_slack_qa15"
  traefik_alb_sns_name = "alb_500_errors_qa15"


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

}