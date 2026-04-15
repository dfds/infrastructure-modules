data "github_repository" "main" {
  full_name = "${var.repo_owner}/${var.repo_name}"
}

locals {
  deploy_name              = "falco"
  default_repo_branch      = data.github_repository.main.default_branch
  repo_branch              = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path        = "clusters/${var.cluster_name}"
  helm_repo_path           = "platform-apps/${var.cluster_name}/${local.deploy_name}/helm"
  app_install_name         = "platform-apps-${local.deploy_name}"
  slack_alert_channel_name = length(var.slack_alert_channel_name) > 0 ? var.slack_alert_channel_name : "#falco-alerts-${var.cluster_name}"
  stream_channel_name      = length(var.stream_channel_name) > 0 ? var.stream_channel_name : "#falco-events-${var.cluster_name}"
}
