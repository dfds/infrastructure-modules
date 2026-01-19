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
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "workload_dns_zone_name" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

# --------------------------------------------------
# EKS
# --------------------------------------------------

variable "eks_cluster_name" {
  type = string
}

# --------------------------------------------------
# CloudWatch Logs
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

variable "alb_access_logs_replication" {
  type = map(object({
    destination_account_id  = string
    destination_bucket_arn  = string
    destination_kms_key_arn = optional(string, "")
    source_kms_key_arn      = optional(string, "")
  }))
  default = {}
}

variable "alb_access_logs_sse_algorithm" {
  type        = string
  description = "The server-side encryption algorithm to use."
  default     = "aws:kms"
  validation {
    condition     = contains(["aws:kms", "aws:kms:dsse", "AES256"], var.alb_access_logs_sse_algorithm)
    error_message = "SSE algorithm must be either 'aws:kms', 'aws:kms:dsse' or 'AES256'."
  }
}


# --------------------------------------------------
# Load Balancers in front of Traefik
# --------------------------------------------------

variable "traefik_alb_anon_deploy" {
  type    = bool
  default = false
}

variable "traefik_alb_anon_core_alias" {
  description = "A list of aliases/alternative names in the *parent* domain, the certificate should also be valid for. E.g. 'prettyurl.company.tld'"
  type        = list(string)
  default     = []
}

variable "traefik_alb_auth_deploy" {
  type    = bool
  default = false
}

variable "traefik_alb_auth_core_alias" {
  description = "A list of aliases/alternative names in the *parent* domain, the certificate should also be valid for. E.g. 'prettyurl.company.tld'"
  type        = list(string)
  default     = []
}

variable "alb_az_app_registration_identifier_urls" {
  type     = list(string)
  default  = null
  nullable = true
}

variable "alb_az_app_registration_additional_owner_ids" {
  description = "List of additional owner object ID for the Azure AD application used by the Auth ALB"
  type        = list(string)
  default     = []
}

# --------------------------------------------------
# Blaster
# --------------------------------------------------

variable "blaster_deploy" {
  type    = bool
  default = false
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

variable "cloudwatch_alarm_log_anomaly_deploy" {
  type    = bool
  default = false
}

# --------------------------------------------------
# Flux CD
# --------------------------------------------------

variable "fluxcd_version" {
  type = string
}

variable "fluxcd_prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}

variable "fluxcd_bootstrap_repo_name" {
  type = string
}

variable "fluxcd_bootstrap_repo_branch" {
  type    = string
  default = "main"
}

variable "fluxcd_bootstrap_repo_owner" {
  type    = string
  default = "dfds"
}

variable "fluxcd_bootstrap_repo_owner_token" {
  type      = string
  sensitive = true
}

variable "fluxcd_tenants" {
  type = list(object({
    namespace = string
    repositories = list(object({
      url    = string
      branch = string
      path   = optional(string, null),
    }))
  }))
  description = "List of tenants' namespaces and repository URLs"
  default     = []
}

variable "fluxcd_source_controller_role_arn" {
  type        = string
  default     = ""
  description = "The ARN of the IAM role for the source controller. Used for IAM roles for service accounts (IRSA). Optional."
}

# --------------------------------------------------
# GitOps apps used by Flux CD
# --------------------------------------------------

variable "fluxcd_apps_git_provider_url" {
  type        = string
  default     = "https://github.com/"
  description = "The URL to your Git server."
}

variable "fluxcd_apps_repo_name" {
  type        = string
  default     = "platform-apps"
  description = "The repo name for your GitOps manifests"
}

variable "fluxcd_apps_repo_branch" {
  type        = string
  default     = "main"
  description = "The default branch for your GitOps manifests"
}

variable "fluxcd_apps_repo_tag" {
  type        = string
  default     = ""
  description = "Use a release tag instead of branch for your GitOps manifests. Tags beat branches if both are set."
}

variable "fluxcd_apps_repo_owner" {
  type        = string
  default     = "dfds"
  description = "The repo owner for your GitOps manifests"
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
  type        = string
  default     = null
  description = "Github token that the provider uses to perform Github operations. Leaving unset will fall back to GITHUB_TOKEN environment variable"
}

variable "atlantis_github_owner" {
  type        = string
  default     = "dfds"
  description = "Github owner(username). Leaving unset will use GITHUB_OWNER environment variable if exists"
}

variable "atlantis_github_username" {
  type        = string
  default     = null
  description = "Github username of the account that owns the token. Leaving unset will use GITHUB_USERNAME environment variable if exists"
}

variable "atlantis_github_repositories" {
  description = "List of repositories to whitelist for Atlantis"
  type        = list(string)
  default     = []
}

variable "atlantis_resources_requests_cpu" {
  type        = string
  default     = "100m"
  description = "CPU resources request size"
}

variable "atlantis_resources_requests_memory" {
  type        = string
  default     = "1536Mi"
  description = "Memory resources requests size"
}

# --------------------------------------------------
# Traefik v2 through Flux CD
# --------------------------------------------------

# Using the variant variables one can perform a blue/green update on Traefik,
# routing traffic gradually to a new version and then decommissioning an older
# version without downtime.

variable "traefik_blue_variant_http_nodeport" {
  type        = number
  description = "Nodeport used by ALB's to connect to the Traefik instance"
  default     = 31000
}

variable "traefik_blue_variant_admin_nodeport" {
  type        = number
  description = "Nodeport used by ALB's to connect to the Traefik instance admin page"
  default     = 31001
}

variable "traefik_blue_variant_deploy" {
  type    = bool
  default = true
}

variable "traefik_blue_variant_weight" {
  type        = number
  description = "The weight of the Traefik instance target groups in the load balancers. Only relevant if there is variant instance deployed."
  default     = 1
}

# Green variant

variable "traefik_green_variant_http_nodeport" {
  type        = number
  description = "Nodeport used by ALB's to connect to the Traefik green variant instance"
  default     = 32000
}

variable "traefik_green_variant_admin_nodeport" {
  type        = number
  description = "Nodeport used by ALB's to connect to the Traefik green variant instance admin page"
  default     = 32001
}

variable "traefik_green_variant_deploy" {
  type        = bool
  description = "Whether to deploy the Traefik green variant."
  default     = false
}

variable "traefik_green_variant_weight" {
  type        = number
  description = "The weight of the Traefik green variant instance target groups in the load balancers."
  default     = 0
}

# --------------------------------------------------
# Velero - requires that s3-bucket-velero module
# is already applied through Terragrunt.
# --------------------------------------------------

variable "velero_deploy" {
  type        = bool
  default     = false
  description = "Should Velero Helm chart be deployed?"
}

variable "velero_cron_schedule" {
  type        = string
  default     = "0 0 * * *"
  description = "Cron-formatted scheduled time for the Velero backup."
}

variable "velero_log_level" {
  type        = string
  default     = "info"
  description = "Velero log level."
  validation {
    condition     = contains(["info", "debug", "warning", "error", "fatal", "panic"], var.velero_log_level)
    error_message = "Invalid value for log_level. Valid values: info, debug, warning, error, fatal, panic."
  }
}

variable "velero_image_tag" {
  type        = string
  default     = ""
  description = "Override the image tag in the Helm chart with a custom version"
}

variable "velero_plugin_for_aws_version" {
  type        = string
  default     = "v1.14.1"
  description = "The version of velero-plugin-for-aws to use as initContainer"
  validation {
    condition     = can(regex("^v(\\d+\\.\\d+)(\\.\\d+)?(-rc\\.\\d+|-beta\\.\\d+)?$", var.velero_plugin_for_aws_version)) || var.velero_plugin_for_aws_version == ""
    error_message = "Velero plugin for AWS must specify a version. The version must start with the letter v and followed by a semantic version number."
  }
}

variable "velero_plugin_for_azure_version" {
  type        = string
  default     = "v1.12.1"
  description = "The version of velero-plugin-for-azure to use as initContainer"
  validation {
    condition     = can(regex("^v(\\d+\\.\\d+)(\\.\\d+)?(-rc\\.\\d+|-beta\\.\\d+)?$", var.velero_plugin_for_azure_version)) || var.velero_plugin_for_azure_version == ""
    error_message = "Velero plugin for Azure must specify a version. The version must start with the letter v and followed by a semantic version number."
  }
}

variable "velero_snapshots_enabled" {
  type        = bool
  default     = false
  description = "Should Velero create snapshot on backups?"
}

variable "velero_node_agent_enabled" {
  type        = bool
  default     = false
  description = "Should Velero enable the node agent?"
}

variable "velero_service_account" {
  type        = string
  default     = "velero-server"
  description = "The service account to be used by Velero"
}

variable "velero_bucket_arn" {
  type        = string
  default     = null
  description = "The arn of the S3 bucket that contains the Velero backup. Only used if S3 bucket is in a different account"
}

variable "velero_excluded_cluster_scoped_resources" {
  type        = list(string)
  default     = []
  description = "List of cluster-scoped resources to exclude from backup"
}

variable "velero_excluded_namespace_scoped_resources" {
  type        = list(string)
  default     = []
  description = "List of namespace-scoped resources to exclude from backup"
}

variable "velero_read_only" {
  type        = bool
  default     = false
  description = <<EOF
    Set to true to access the backup storage location in read-only mode.
    This is useful for restoring from a backup without modifying the backup storage location.
EOF
}

variable "velero_ebs_csi_kms_arn" {
  type        = string
  default     = ""
  description = "The KMS ARN to use for EBS CSI volumes."
}

variable "velero_enable_azure_storage" {
  type        = bool
  default     = true
  description = "Enable Azure storage for Velero backups"
}

variable "velero_azure_resource_group_name" {
  type        = string
  default     = ""
  description = "The name of the Azure resource group where the storage account is located"
}

variable "velero_azure_storage_account_name" {
  type        = string
  default     = ""
  description = "The name of the Azure storage account where the Velero backups will be stored"

}

variable "velero_azure_subscription_id" {
  type        = string
  default     = ""
  description = "The Azure subscription ID where the storage account is located"

}

variable "velero_azure_bucket_name" {
  type        = string
  default     = "velero-backup"
  description = "The name of the Azure storage container where Velero backups will be stored"
}

variable "velero_azure_credentials_secret_name" {
  type        = string
  default     = "velero-credentials"
  description = "The name of the Kubernetes secret containing Azure credentials for Velero"
}

variable "velero_cron_schedule_offsite" {
  type        = string
  default     = "0 2 1 * *"
  description = "Cron-formatted scheduled time for offsite backups."
}

variable "velero_cron_schedule_offsite_ttl" {
  type        = string
  default     = "8640h"
  description = "Time to live for the scheduled offsite backup."
}

# --------------------------------------------------
# Inactivity based clean up for sandboxes
# --------------------------------------------------

variable "enable_inactivity_cleanup" {
  type        = bool
  default     = true
  description = "Enables automated clean up of ELB resources based on inactivity. Only applicable to sandboxes."
}

# --------------------------------------------------
# Grafana Agent for Kubernetes monitoring
# --------------------------------------------------

variable "grafana_deploy" {
  type        = string
  default     = false
  description = "Feature toggle for Grafana module"
}

variable "grafana_agent_api_token" {
  type        = string
  description = "The token to authenticate request to a Grafana Cloud stack"
  default     = ""
  sensitive   = true
}

variable "grafana_agent_prometheus_url" {
  type        = string
  description = "The Prometheus URL in a Grafana Cloud stack"
  default     = ""
}

variable "grafana_agent_prometheus_username" {
  type        = string
  description = "The username for Prometheus in a Grafana Cloud stack"
  default     = ""
}

variable "grafana_agent_loki_url" {
  type        = string
  description = "The Loki URL in a Grafana Cloud stack"
  default     = ""
}

variable "grafana_agent_loki_username" {
  type        = string
  description = "The username for Loki in a Grafana Cloud stack"
  default     = ""
}

variable "grafana_agent_tempo_url" {
  type        = string
  description = "The Tempo URL in a Grafana Cloud stack"
  default     = ""
}

variable "grafana_agent_tempo_username" {
  type        = string
  description = "The username for Tempo in a Grafana Cloud stack"
  default     = ""
}

variable "grafana_agent_traces_enabled" {
  type        = bool
  default     = true
  description = "Enable traces or not. Default: true"
}

variable "grafana_agent_open_cost_enabled" {
  type        = bool
  default     = false
  description = "Enable Open Cost or not. Default: false"
}

variable "grafana_agent_resource_memory_limit" {
  type        = string
  default     = "20Gi"
  description = "Set resource memory limits on Grafana Agent container"
}

variable "grafana_agent_resource_memory_request" {
  type        = string
  default     = "4Gi"
  description = "Set resource memory request on Grafana Agent container"
}

variable "grafana_agent_replicas" {
  type        = number
  default     = 1
  description = "How many replicas to run Grafana Agent with"
}

variable "grafana_agent_storage_size" {
  type        = string
  description = "Storage size for Grafana Persistent Volume"
  default     = "5Gi"
}

variable "observability_tolerations" {
  type = list(object({
    key      = string,
    operator = string,
    value    = optional(string),
    effect   = string,
  }))
  description = "Tolerations to apply to the cluster-wide observability workloads."
  default     = []
}

variable "observability_affinity" {
  type = list(object({
    key      = string,
    operator = string,
    values   = list(string)
  }))
  description = "Affinities to apply to the cluster-wide observability workloads."
  default     = []
}

# --------------------------------------------------
# External Secrets with SSM
# --------------------------------------------------

variable "external_secrets_ssm_service_account" {
  type        = string
  default     = "*"
  description = "The service account (or wildcard) to be used by an SecretStore"
}

variable "external_secrets_ssm_allowed_namespaces" {
  type        = list(string)
  default     = ["atlantis", "flux-system"]
  description = "The namespaces that can use IRSA to access external secrets"
}

# --------------------------------------------------
# External DNS
# --------------------------------------------------

variable "external_dns_deploy" {
  type        = string
  default     = false
  description = "Feature toggle for External DNS module"
}

variable "external_dns_traefik_alb_anon_core_alias" {
  description = "A list of aliases/alternative names to be managed by External DNS in the *parent* domain. E.g. 'prettyurl.company.tld'"
  type        = list(string)
  default     = []
}

variable "external_dns_traefik_alb_auth_core_alias" {
  description = "A list of aliases/alternative names for the login-protected services to be managed by External DNS in the *parent* domain. E.g. 'prettyurl.company.tld'"
  type        = list(string)
  default     = []
}

variable "external_deletion_policy_override" {
  type        = string
  description = "External DNS deletion policy"
  default     = ""
  validation {
    condition     = contains(["", "sync", "upsert-only"], var.external_deletion_policy_override)
    error_message = "Deletion policy must be either '', 'sync', 'upsert-only'."
  }
}

variable "external_dns_is_debug_mode" {
  type        = bool
  description = "Enable debug logging for External DNS"
  default     = false
}

variable "external_dns_core_route53_assume_role_arn" {
  type        = string
  description = "The ARN of the role to assume in the core account to manage Route53 records"
  default     = ""
}

# --------------------------------------------------
# kafka-exporter
# --------------------------------------------------

variable "kafka_exporter_deploy" {
  type        = string
  default     = false
  description = "Feature toggle for kafka-exporter module"
}

variable "kafka_exporter_clusters" {
  type        = map(any)
  description = "Map of clusters that will be used to deploy exporters"
  default     = {}
}

# --------------------------------------------------
# 1password-connect
# --------------------------------------------------

variable "onepassword-connect_deploy" {
  type        = string
  default     = false
  description = "Feature toggle for 1password connect module"
}

variable "onepassword_credentials_json" {
  type        = string
  default     = ""
  description = "The 1Password Connect credentials JSON"
}

variable "onepassword_token_for_atlantis" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The 1Password Connect tokens to be stored in SSM if Atlantis is enabled"
}

# --------------------------------------------------
# Github ARC SS Controller
# --------------------------------------------------

variable "github_arc_ss_controller_deploy" {
  type        = string
  default     = false
  description = "Feature toggle for Github ARC SS Controller"
}

# --------------------------------------------------
# Github ARC Runners
# --------------------------------------------------

variable "github_arc_runners_deploy" {
  type        = string
  default     = false
  description = "Feature toggle for Github ARC Runners"
}

variable "github_arc_runners_runner_scale_set_name" {
  type        = string
  description = "Name for the runner scale set"
  default     = "dfds-runners"
}

variable "github_arc_runners_resource_memory" {
  type        = string
  description = "Memory request for the runner pods"
  default     = "8Gi"
}

# --------------------------------------------------
# Apache Druid Operator
# --------------------------------------------------

variable "druid_operator_deploy" {
  type        = bool
  description = "Deploy druid_operator helm chart switch"
  default     = true
}

# --------------------------------------------------
# Trivy Operator
# --------------------------------------------------

variable "trivy_operator_deploy" {
  type        = bool
  description = "Deploy Trivy Operator helm chart switch"
  default     = false
}

variable "trivy_operator_resources_requests_cpu" {
  type        = string
  default     = "100m"
  description = "CPU resources request size"
}

variable "trivy_operator_resources_requests_memory" {
  type        = string
  default     = "1Gi"
  description = "Memory resources requests size"
}

variable "trivy_scan_resources_requests_cpu" {
  type        = string
  default     = "100m"
  description = "CPU resources request size"
}

variable "trivy_scan_resources_requests_memory" {
  type        = string
  default     = "512Mi"
  description = "Memory resources requests size"
}

# --------------------------------------------------
# Falco
# --------------------------------------------------

variable "falco_deploy" {
  type        = bool
  description = "Deploy Falco helm chart switch"
  default     = false
}

variable "falco_deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "falco"
}

variable "falco_namespace" {
  type        = string
  description = "The namespace to deploy Falco in"
  default     = "falco"
}

variable "falco_slack_alert_webhook_url" {
  type        = string
  default     = ""
  description = "Value for slack webhook url. If not provided, slack alerts will not be sent"
}

variable "falco_slack_alert_channel_name" {
  type        = string
  default     = ""
  description = "Channel name for slack alerts. Example: #falco-alerts"
}

variable "falco_slack_alert_minimum_priority" {
  type        = string
  default     = "critical"
  description = "Minimum priority level for slack alerts to be sent to Slack"
}

variable "falco_stream_enabled" {
  type        = bool
  default     = false
  description = "Enable Falco stream output to a specified webhook"
}

variable "falco_stream_webhook_url" {
  type        = string
  default     = ""
  description = "Value for webhook url to which to send falco events stream. stream_enabled must be set to true. If not provided, slack stream will not be sent"
}

variable "falco_stream_channel_name" {
  type        = string
  default     = ""
  description = "Channel name for falco stream. Example: #falco-stream"
}

variable "falco_custom_rules" {
  type        = string
  default     = ""
  description = "Custom rules to be added to the falco config"
}

# --------------------------------------------------
# NAT Gateway
# --------------------------------------------------

variable "use_worker_nat_gateway" {
  type        = bool
  default     = false
  description = "Whether to use NAT Gateway for worker nodes"
}

# --------------------------------------------------
# KEDA
# --------------------------------------------------

variable "keda_deploy" {
  type        = bool
  description = "Deploy KEDA helm chart switch"
  default     = true
}