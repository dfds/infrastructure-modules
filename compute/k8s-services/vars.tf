# --------------------------------------------------
# Terraform
# --------------------------------------------------

variable "terraform_state_s3_bucket" {
  type = string
}

variable "terraform_state_region" {
  type = string
}

# --------------------------------------------------
# AWS
# --------------------------------------------------
variable "aws_region" {
  type = string
}

variable "aws_workload_account_id" {
}

variable "aws_assume_role_arn" {
  type = string
}

variable "workload_dns_zone_name" {
}

variable "ssm_param_createdby" {
  type        = string
  description = "The value that will be used for the createdBy key when tagging any SSM parameters"
  default     = null
}

# --------------------------------------------------
# EKS
# --------------------------------------------------

variable "eks_cluster_name" {
  type = string
}


# --------------------------------------------------
# KIAM
# --------------------------------------------------

variable "kiam_chart_version" {
  type        = string
  description = "KIAM helm chart version"
  default     = null
}

variable "kiam_deploy" {
  type    = bool
  default = true
}


# --------------------------------------------------
# FluentD CloudWatch Logs
# --------------------------------------------------

variable "aws_assume_logs_role_arn" {
  type    = string
  default = null
}

# --------------------------------------------------
# ALB access logs S3 bucket
# --------------------------------------------------

variable "traefik_alb_s3_access_logs_retiontion_days" {
  type    = number
  default = 30
}

# --------------------------------------------------
# Load Balancers in front of Traefik
# --------------------------------------------------

variable "traefik_alb_anon_deploy" {
  type    = bool
  default = false
}

variable "traefik_alb_anon_core_alias" {
  description = "A list of aliases/alternative names in the *parent* domain, the certficate should also be valid for. E.g. 'prettyurl.company.tld'"
  type        = list(string)
  default     = []
}

variable "traefik_alb_auth_deploy" {
  type    = bool
  default = false
}

variable "traefik_alb_auth_core_alias" {
  description = "A list of aliases/alternative names in the *parent* domain, the certficate should also be valid for. E.g. 'prettyurl.company.tld'"
  type        = list(string)
  default     = []
}

variable "traefik_nlb_deploy" {
  type    = bool
  default = false
}

variable "traefik_nlb_cidr_blocks" {
  type    = list(string)
  default = []
}

# --------------------------------------------------
# Blaster
# --------------------------------------------------

variable "blaster_deploy" {
  default = false
}

variable "blaster_namespace_extra_permitted_roles" {
  type        = list(string)
  default     = []
  description = "Additional role names or ARNs that can be assumed from this namespace through KIAM"
}


# --------------------------------------------------
# Cloudwatch alarms and alarm notifier (Slack)
# --------------------------------------------------

variable "slack_webhook_url" {
  type    = string
  default = ""
}

variable "alarm_notifier_deploy" {
  type    = bool
  default = false
}

variable "cloudwatch_alarm_alb_targets_health_deploy" {
  type    = bool
  default = false
}

variable "cloudwatch_alarm_alb_5XX_deploy" {
  type    = bool
  default = false
}

# --------------------------------------------------
# Monitoring namespace
# --------------------------------------------------

variable "monitoring_namespace_deploy" {
  type        = bool
  description = "Deploy monitoring namespace"
  default     = true
}

variable "monitoring_namespace_iam_roles" {
  type        = string
  description = "IAM roles allowed to assume"
  default     = ""
  validation {
    condition = var.monitoring_namespace_iam_roles == "" ? true : (
      can(regex("^arn:aws:iam::", var.monitoring_namespace_iam_roles))
    )
    error_message = "The value must contain full role ARNs."
  }
}

# --------------------------------------------------
# Goldpinger
# --------------------------------------------------

variable "monitoring_goldpinger_deploy" {
  type        = bool
  description = "Deploy goldpinger helm chart switch"
  default     = false
}

variable "monitoring_goldpinger_chart_version" {
  type        = string
  description = "Goldpinger helm chart version"
  default     = null
}

variable "monitoring_goldpinger_priority_class" {
  type        = string
  description = "Goldpinger daemonset priority class name"
  default     = "cluster-monitoring"
}

# --------------------------------------------------
# Kube-prometheus-stack
# --------------------------------------------------

variable "monitoring_kube_prometheus_stack_deploy" {
  type        = bool
  description = "Deploy kube-prometheus-stack helm chart switch"
  default     = false
}

variable "monitoring_kube_prometheus_stack_chart_version" {
  type        = string
  description = "Kube-prometheus-stack helm chart version"
  default     = null
}

variable "monitoring_kube_prometheus_stack_priority_class" {
  type        = string
  description = "Kube-prometheus-stack components priority class name"
  default     = "cluster-monitoring"
}

variable "monitoring_kube_prometheus_stack_grafana_admin_password" {
  type        = string
  description = "Grafana admin password"
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  sensitive   = true
}

variable "monitoring_kube_prometheus_stack_grafana_ingress_path" {
  type        = string
  description = "Grafana ingress path"
  default     = "/infrastructure"
}

variable "monitoring_kube_prometheus_stack_grafana_notifier_name" {
  type        = string
  description = "Grafana alert notifier name"
  default     = "notifier1"
}

variable "monitoring_kube_prometheus_stack_grafana_serviceaccount_name" {
  type        = string
  description = "Grafana serviceaccount to be used for pod"
  default     = "grafana-cloudwatch"
}

variable "monitoring_kube_prometheus_stack_slack_webhook" {
  type        = string
  description = "Kube-prometheus-stack alert slack webhook"
  default     = ""
}

variable "monitoring_kube_prometheus_stack_prometheus_storageclass" {
  type        = string
  description = "Prometheus storage class"
  default     = "csi-gp2"
}

variable "monitoring_kube_prometheus_stack_prometheus_storage_size" {
  type        = string
  description = "Promehteus storage size"
  default     = "50Gi"
}

variable "monitoring_kube_prometheus_stack_prometheus_retention" {
  type        = string
  description = "Promehteus retention"
  default     = "30d"
}

variable "monitoring_kube_prometheus_stack_slack_channel" {
  type        = string
  description = "Kube-prometheus-stack alert slack channel"
  default     = ""
}

variable "monitoring_kube_prometheus_stack_target_namespaces" {
  type        = string
  description = "Alert target namespaces filter"
  default     = ".*"
}

variable "monitoring_kube_prometheus_stack_github_owner" {
  type        = string
  description = "Name of the Treaefik Flux repo Github owner (previously: organization)"
  default     = null
}

variable "monitoring_kube_prometheus_stack_repo_name" {
  type        = string
  description = "Name of the Github repo to store the Traefik Flux manifests in"
  default     = null
}

variable "monitoring_kube_prometheus_stack_repo_branch" {
  type        = string
  description = "Override the default branch of the Traefik Flux repo (optional)"
  default     = null
}

variable "monitoring_kube_prometheus_stack_prometheus_request_memory" {
  type        = string
  description = "Prometheus resource setting for memory request"
  default     = "512Mi"
}

variable "monitoring_kube_prometheus_stack_prometheus_request_cpu" {
  type        = string
  description = "Prometheus resource setting for cpu request"
  default     = "500m"
}

variable "monitoring_kube_prometheus_stack_prometheus_limit_memory" {
  type        = string
  description = "Prometheus resource setting for limit memory"
  default     = "2Gi"
}

variable "monitoring_kube_prometheus_stack_prometheus_limit_cpu" {
  type        = string
  description = "Prometheus resource setting for limit cpu"
  default     = "1000m"
}


# --------------------------------------------------
# Metrics-Server
# --------------------------------------------------

variable "monitoring_metrics_server_deploy" {
  type        = bool
  description = "Deploy metrics-server helm chart switch. If setting to true, monitoring_namespace_deploy must also be set to true"
  default     = true
}

variable "monitoring_metrics_server_chart_version" {
  type        = string
  description = "metrics-server helm chart version"
  default     = null
}

variable "monitoring_metrics_server_repo_url" {
  type        = string
  description = "The repository URL for the metrics-server Helm chart"
  default     = "https://kubernetes-sigs.github.io/metrics-server/"
}

# --------------------------------------------------
# Unused variables - to provent TF warning/error:
# Using a variables file to set an undeclared variable is deprecated and will
# become an error in a future release. If you wish to provide certain "global"
# settings to all configurations in your organization, use TF_VAR_...
# environment variables to set these instead.
# --------------------------------------------------

variable "eks_public_s3_bucket" {
  type    = string
  default = ""
}

variable "eks_is_sandbox" {
  type    = bool
  default = false
}

# --------------------------------------------------
# Platform Flux CD
# --------------------------------------------------

variable "platform_fluxcd_deploy" {
  type        = bool
  default     = false
  description = ""
}

variable "platform_fluxcd_release_tag" {
  type        = string
  default     = null
  description = "The release tag of Flux CD to use."
}

variable "platform_fluxcd_namespace" {
  type        = string
  default     = "platform-flux"
  description = ""
}

variable "platform_fluxcd_repo_name" {
  type        = string
  default     = ""
  description = ""
}

variable "platform_fluxcd_repo_path" {
  type        = string
  default     = ""
  description = ""
}

variable "platform_fluxcd_github_owner" {
  type        = string
  default     = ""
  description = ""
}

variable "platform_fluxcd_github_token" {
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = ""
}

variable "platform_fluxcd_repo_branch" {
  type        = string
  default     = "main"
  description = ""
}

# --------------------------------------------------
# Namespaces
# --------------------------------------------------

variable "kubesystem_permitted_extra_roles" {
  type        = list(string)
  default     = []
  description = "Defines additional roles that can be assumed from the kube-system namespace"
}


# --------------------------------------------------
# Atlantis
# --------------------------------------------------

variable "atlantis_deploy" {
  type        = bool
  description = "Deploy Atlantis"
  default     = false
}

variable "atlantis_github_token" {
  description = "Github token that the provider uses to perform Github operations. Leaving unset will fall back to GITHUB_TOKEN environment variable"
  default     = null
}

variable "atlantis_platform_fluxcd_github_token" {
  description = "Github token that the provider uses to perform Github operations for Flux."
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
}

variable "atlantis_github_owner" {
  description = "Github owner(username). Conflicts with github_organization. Leaving unset will use GITHUB_OWNER environment variable if exists"
  default     = null
}

variable "atlantis_github_username" {
  description = "Github username of the account that will post Atlantis comments on PR's"
  default     = null
}

variable "atlantis_github_repositories" {
  description = "List of repositories to whitelist for Atlantis"
  type        = list(string)
  default     = []
}

variable "atlantis_webhook_content_type" {
  default = "application/json"
}

variable "atlantis_webhook_insecure_ssl" {
  default = false
}

variable "atlantis_webhook_events" {
  description = "A list of events that should trigger the webhook"
  default     = []
  type        = list(string)
}

variable "atlantis_namespace" {
  type        = string
  description = "Namespace for Atlantis deployment"
  default     = "atlantis"
}

variable "atlantis_chart_version" {
  type        = string
  description = "Version of the helm chart to deploy"
  default     = null
}

variable "atlantis_ingress" {
  type        = string
  description = "URL for Atlantis Ingress"
  default     = null
}

variable "atlantis_image" {
  type        = string
  description = "Name of the image to use for Atlantis"
  default     = "dfdsdk/atlantis-prime-pipeline"
}

variable "atlantis_image_tag" {
  type        = string
  description = "Tag of the Atlantis image to use"
  default     = "latest"
}

variable "atlantis_arm_tenant_id" {
  type        = string
  description = "Used to set environment variable for ARM tenant ID"
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
}

variable "atlantis_arm_subscription_id" {
  type        = string
  description = "Used to set environment variable for ARM subscription ID"
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
}

variable "atlantis_arm_client_id" {
  type        = string
  description = "Used to set environment variable for ARM client ID"
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
}

variable "atlantis_arm_client_secret" {
  type        = string
  description = "Used to set environment variable for ARM client secret"
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
}

variable "atlantis_aws_access_key" {
  description = "AWS Access Key"
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
}

variable "atlantis_aws_secret" {
  description = "AWS Secret"
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
}

variable "atlantis_access_key_master" {
  type        = string
  description = "Access Key for Core account"
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
}

variable "atlantis_secret_key_master" {
  type        = string
  description = "Secret for Core account"
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
}

variable "atlantis_storage_class" {
  type        = string
  description = "Storage class to use for persistent volume"
  default     = "csi-gp2"
}

variable "atlantis_flux_repo_name" {
  type        = string
  description = "Name of the Github repo to store the Atlantis Flux manifests in"
  default     = null
}

variable "atlantis_flux_repo_owner" {
  type        = string
  description = "Github username or organization that owns the repo to store the Atlantis Flux manifests in"
  default     = null
}

variable "atlantis_flux_repo_branch" {
  type        = string
  description = "Override the default branch of the Atlantis Flux repo (optional)"
  default     = "main"
}

# --------------------------------------------------
# Crossplane
# --------------------------------------------------

variable "crossplane_deploy" {
  type        = bool
  description = "Deploy Crossplane"
  default     = false
}

variable "crossplane_namespace" {
  type        = string
  description = "Namespace in which to install Crossplane"
  default     = "upbound-system"
}

variable "crossplane_release_name" {
  type        = string
  description = "Name of the chart release"
  default     = "universal-crossplane"
}

variable "crossplane_chart_version" {
  type        = string
  description = "Specify a version of the Helm chart"
  default     = null
}

variable "crossplane_recreate_pods" {
  type        = bool
  description = "Recreate pods on deployment"
  default     = true
}

variable "crossplane_force_update" {
  type        = bool
  description = "Force resource updates through replacement"
  default     = false
}


variable "crossplane_devel" {
  type        = bool
  description = "Allow use of development versions of Crossplane"
  default     = true
}


variable "crossplane_providers" {
  type        = list(string)
  description = "List of Crossplane providers to install"
  default     = []
}

variable "crossplane_admin_service_accounts" {
  type = list(object({
    serviceaccount = string
    namespace      = string
  }))
  description = "List of service account objects that should have crossplane-admin access"
  default     = []
}

variable "crossplane_edit_service_accounts" {
  type = list(object({
    serviceaccount = string
    namespace      = string
  }))
  description = "List of service account objects that should have crossplane-edit access"
  default     = []
}

variable "crossplane_view_service_accounts" {
  type = list(object({
    serviceaccount = string
    namespace      = string
  }))
  description = "List of service account objects that should have crossplane-view access"
  default     = []
}

variable "crossplane_metrics_enabled" {
  type        = bool
  description = "Enable crossplane metrics"
  default     = true
}

variable "crossplane_aws_iam_role_name" {
  type        = string
  description = ""
  default     = "provider-aws"
}

variable "crossplane_cfg_pkg_deploy" {
  type        = bool
  description = "Deploy Crossplane configuration package"
  default     = false
}

variable "crossplane_cfg_pkg_repo_owner" {
  type        = string
  description = "Name of the Flux manifests repo Github owner"
  default     = null
}

variable "crossplane_cfg_pkg_repo_name" {
  type        = string
  description = "Name of the Github repo to store the Flux manifests in"
  default     = null
}

variable "crossplane_cfg_pkg_repo_branch" {
  type        = string
  description = "Override the default branch of the Flux manifests repo (optional)"
  default     = null
}

variable "crossplane_cfg_pkg_name" {
  type        = string
  description = "The unique Crossplane configuration name in Kubernetes"
  default     = "dfdsdk-dfds-infra"
}

variable "crossplane_cfg_pkg_docker_image" {
  type        = string
  description = "The Docker image address the crossplane configuration we want to deploy, e.g.: dfdsdk/dfds-infra:v0.0.1"
  default     = null
}

variable "crossplane_operator_deploy" {
  type        = bool
  description = "Deploy Crossplane configuration package"
  default     = false
}

variable "crossplane_operator_repo_owner" {
  type        = string
  description = "Name of the Flux manifests repo Github owner"
  default     = null
}

variable "crossplane_operator_repo_name" {
  type        = string
  description = "Name of the Github repo to store the Flux manifests in"
  default     = null
}

variable "crossplane_operator_repo_branch" {
  type        = string
  description = "Override the default branch of the Flux manifests repo (optional)"
  default     = null
}

variable "crossplane_operator_deploy_name" {
  type        = string
  description = "The unique name for this deployment."
  default     = "crossplane-operator"
}

variable "crossplane_operator_helm_chart_version" {
  type        = string
  description = "The Helm Chart version to deploy."
  default     = null
}

variable "crossplane_provider_confluent_email" {
  type        = string
  default     = null
  description = "Confluent global admin account email"
}

variable "crossplane_provider_confluent_password" {
  type        = string
  default     = null
  description = "Confluent global admin account password"
  sensitive   = true
}

variable "crossplane_confluent_environments" {
  type        = map(any)
  default     = {}
  description = "Supported Confluent environments"
}

variable "crossplane_confluent_clusters" {
  type        = map(any)
  default     = {}
  description = "Supported Confluent clusters"
}

variable "crossplane_confluent_clusters_endpoints" {
  type        = map(any)
  default     = {}
  description = "Endpoints for each supported supported Confluent clusters"
}

# -------------

variable "kiam_strict_mode_disabled" {
  type        = bool
  description = "Disable default strict namespace regexp when matching roles"
  default     = false
}

# --------------------------------------------------
# Traefik v2 through Flux CD
# --------------------------------------------------

variable "traefik_flux_github_owner" {
  type        = string
  description = "Name of the Treaefik Flux repo Github owner (previously: organization)"
  default     = null
}

variable "traefik_flux_repo_name" {
  type        = string
  description = "Name of the Github repo to store the Traefik Flux manifests in"
  default     = null
}

variable "traefik_flux_repo_branch" {
  type        = string
  description = "Override the default branch of the Traefik Flux repo (optional)"
  default     = null
}

variable "traefik_flux_helm_chart_version" {
  type        = string
  description = "Helm Chart version to be used to deploy Traefik"
  default     = null
}

variable "traefik_flux_http_nodeport" {
  type        = number
  description = "Nodeport used by ALB's to connect to the Traefik instance"
  default     = 31000
}

variable "traefik_flux_admin_nodeport" {
  type        = number
  description = "Nodeport used by ALB's to connect to the Traefik instance admin page"
  default     = 31001
}

variable "traefik_flux_health_check_path" {
  description = "Which path should the LB call when checking if Traefik v2 service is healthy"
  type        = string
  default     = "/ping/"
}

variable "traefik_flux_additional_args" {
  type        = list(any)
  description = "Pass arguments to the additionalArguments node in the Traefik Helm chart"
  default     = ["--metrics.prometheus"]
}

variable "traefik_flux_deploy" {
  type    = bool
  default = true
}

variable "traefik_flux_dashboard_deploy" {
  type        = bool
  description = "Deploy ingressroute for external access to Traefik dashboard."
  default     = true
}

# --------------------------------------------------
# Blackbox Exporter
# --------------------------------------------------

variable "blackbox_exporter_deploy" {
  type        = bool
  description = "Should the Blackbox Exporter be deployed through Flux?"
  default     = false
}

variable "blackbox_exporter_helm_chart_version" {
  type        = string
  description = "Helm Chart version to be used to deploy Traefik"
  default     = null
}

variable "blackbox_exporter_github_owner" {
  type        = string
  description = "Name of the Flux manifests repo Github owner"
  default     = null
}

variable "blackbox_exporter_repo_name" {
  type        = string
  description = "Name of the Github repo to store the Flux manifests in"
  default     = null
}

variable "blackbox_exporter_repo_branch" {
  type        = string
  description = "Override the default branch of the Flux manifests repo (optional)"
  default     = null
}

variable "blackbox_exporter_monitoring_targets" {
  type        = list(object({ name = string, url = string, module = string }))
  description = "Complex object of what to monitor with Blackbox Exporter"
  default     = []
}

# --------------------------------------------------
# Podinfo through Flux CD
# --------------------------------------------------

variable "podinfo_flux_github_owner" {
  type        = string
  description = "Name of the Flux repo Github owner (previously: organization)"
  default     = null
}

variable "podinfo_flux_repo_name" {
  type        = string
  description = "Name of the Github repo to store the podinfo Flux manifests in"
  default     = null
}

variable "podinfo_flux_repo_branch" {
  type        = string
  description = "Override the default branch of the podinfo Flux repo (optional)"
  default     = null
}

variable "podinfo_flux_deploy" {
  type    = bool
  default = false
}

# --------------------------------------------------
# fluentd-cloudwatch through Flux
# --------------------------------------------------

variable "fluentd_cloudwatch_flux_github_owner" {
  type        = string
  description = "Name of the Flux repo Github owner (previously: organization)"
  default     = null
}

variable "fluentd_cloudwatch_flux_repo_name" {
  type        = string
  description = "Name of the Github repo to store the fluentd-cloudwatch Flux manifests in"
  default     = null
}

variable "fluentd_cloudwatch_flux_repo_branch" {
  type        = string
  description = "Override the default branch of the fluentd-cloudwatch Flux repo (optional)"
  default     = null
}

variable "fluentd_cloudwatch_flux_deploy" {
  type    = bool
  default = false
}

variable "fluentd_cloudwatch_account_id" {
  type        = string
  description = "The account id that owns the cloudwatch logs from fluentd."
  default     = null
}

variable "fluentd_cloudwatch_retention_in_days" {
  type        = string
  default     = "7"
  description = "How many days to keep the logs?"
}

# --------------------------------------------------
# Velero - requires that s3-bucket-velero module
# is already applied through Terragrunt.
# --------------------------------------------------

variable "velero_flux_deploy" {
  type        = bool
  default     = false
  description = "Should Velero Helm chart be deployed?"
}

variable "velero_flux_deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "velero"
}

variable "velero_flux_role_arn" {
  type        = string
  description = "The ARN for the role that is permitted to use Velero backup storage."
  default     = null
}

variable "velero_flux_bucket_name" {
  type        = string
  default     = null
  description = "The name of the S3 bucket that contains the Velero backup"
}

variable "velero_flux_snapshots_enabled" {
  type        = bool
  default     = false
  description = "Should Velero use snapshot backups?"

}

variable "velero_flux_log_level" {
  type        = string
  default     = "info"
  description = "Velero log level."
  validation {
    condition     = contains(["info", "debug", "warning", "error", "fatal", "panic"], var.velero_flux_log_level)
    error_message = "Invalid value for log_level. Valid values: info, debug, warning, error, fatal, panic."
  }
}

variable "velero_flux_cron_schedule" {
  type        = string
  default     = "0 0 * * *"
  description = "Cron format scheuled time."
}

variable "velero_flux_schedules_template_ttl" {
  type        = string
  default     = "336h"
  description = "Time to live for the scheduled backup."
}

variable "velero_flux_schedules_template_snapshot_volumes" {
  type        = bool
  default     = false
  description = "Should Velero use snapshot volumes?"
}

variable "velero_flux_schedules_template_include_cluster_resources" {
  type        = bool
  default     = false
  description = "Should Velero also backup cluster resources?"
}

variable "velero_flux_github_owner" {
  type        = string
  description = "Name of the Flux repo Github owner (previously: organization)"
  default     = null
}

variable "velero_flux_repo_name" {
  type        = string
  description = "Name of the Github repo to store the Flux manifests in"
  default     = null
}

variable "velero_flux_repo_branch" {
  type        = string
  description = "Override the default branch of the Flux repo (optional)"
  default     = null
}

variable "velero_helm_chart_version" {
  type        = string
  default     = ""
  description = "The Velero Helm chart version to install"
}

variable "velero_image_tag" {
  type        = string
  default     = ""
  description = "Override the image tag in the Helm chart with a custom version"
}

variable "velero_plugin_for_aws_version" {
  type        = string
  default     = "v1.4.1"
  description = "The version of velero-plugin-for-aws to use as initContainer"
  validation {
    condition     = can(regex("^v[[:digit:]].[[:digit:]].[[:digit:]]+", var.velero_plugin_for_aws_version)) || var.velero_plugin_for_aws_version == ""
    error_message = "Velero plugin for AWS must specify a version. The version must start with the letter v and followed by a semantic version number."
  }
}

variable "velero_plugin_for_csi_version" {
  type        = string
  default     = "v0.2.0"
  description = "The version of velero-plugin-for-csi to use as initContainer"
  validation {
    condition     = can(regex("^v[[:digit:]].[[:digit:]].[[:digit:]]+", var.velero_plugin_for_csi_version)) || var.velero_plugin_for_csi_version == ""
    error_message = "Velero plugin for CSI must specify a version. The version must start with the letter v and followed by a semantic version number."
  }
}

variable "kyverno_chart_version" {
  type        = string
  default     = "v2.4.1"
  description = "Helm chart version of Kyverno"
}

variable "kyverno_deploy" {
  type        = string
  default     = true
  description = "Feature toggle for Kyverno module"
}

variable "kyverno_replicas" {
  type        = number
  default     = 3
  description = "Number of replica pods for Kyverno"
}
