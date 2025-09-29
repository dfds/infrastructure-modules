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

variable "blaster_namespace_labels" {
  type    = map(any)
  default = { "pod-security.kubernetes.io/enforce" = "baseline" }
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
# Monitoring namespace
# --------------------------------------------------

variable "monitoring_namespace_deploy" {
  type        = bool
  description = "Deploy monitoring namespace"
  default     = true
}

variable "monitoring_namespace_labels" {
  type    = map(any)
  default = { "pod-security.kubernetes.io/audit" = "baseline", "pod-security.kubernetes.io/enforce" = "privileged" }
}

variable "monitoring_tolerations" {
  type = list(object({
    key      = string,
    operator = string,
    value    = optional(string),
    effect   = string,
  }))
  description = "Tolerations to apply to the cluster-wide monitoring workloads."
  default     = []
}

variable "monitoring_affinity" {
  type = list(object({
    key      = string,
    operator = string,
    values   = list(string)
  }))
  description = "Affinities to apply to the cluster-wide monitoring workloads."
  default     = []
}

# --------------------------------------------------
# Goldpinger
# --------------------------------------------------

variable "goldpinger_deploy" {
  type        = bool
  description = "Deploy goldpinger helm chart switch"
  default     = false
}

variable "goldpinger_namespace" {
  type        = string
  description = "The namespace to deploy goldpinger in"
  default     = "goldpinger"
}

variable "goldpinger_chart_version" {
  type        = string
  description = "Goldpinger helm chart version"
  default     = ""
}

# --------------------------------------------------
# Metrics-Server
# --------------------------------------------------

variable "metrics_server_deploy" {
  type        = bool
  description = "Deploy metrics-server helm chart switch."
  default     = true
}

variable "metrics_server_helm_chart_version" {
  type        = string
  description = "The helm chart version"
  default     = ""
}


# --------------------------------------------------
# Flux CD
# --------------------------------------------------

variable "fluxcd_version" {
  type    = string
  default = null
}

variable "fluxcd_prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}

variable "fluxcd_bootstrap_repo_name" {
  type    = string
  default = ""
}

variable "fluxcd_bootstrap_repo_branch" {
  type    = string
  default = "main"
}

variable "fluxcd_bootstrap_repo_owner" {
  type    = string
  default = ""
}

variable "fluxcd_bootstrap_repo_owner_token" {
  type    = string
  default = "" #tfsec:ignore:general-secrets-sensitive-in-variable
}

variable "fluxcd_bootstrap_overwrite_on_create" {
  type        = bool
  default     = true
  description = "Enable overwriting existing files"
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
  default     = ""
  description = "The repo name for your GitOps manifests"
}

variable "fluxcd_apps_repo_branch" {
  type        = string
  default     = "main"
  description = "The default branch for your GitOps manifests"
}

variable "fluxcd_apps_repo_owner" {
  type        = string
  default     = "main"
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
  default     = null
  description = "Github owner(username). Conflicts with github_organization. Leaving unset will use GITHUB_OWNER environment variable if exists"
}

variable "atlantis_github_username" {
  type        = string
  default     = null
  description = "Github username of the account that will post Atlantis comments on PR's"
}

variable "atlantis_github_repositories" {
  description = "List of repositories to whitelist for Atlantis"
  type        = list(string)
  default     = []
}

variable "atlantis_webhook_events" {
  description = "A list of events that should trigger the webhook"
  default     = ["issue_comment", "pull_request", "pull_request_review", "push"]
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
  default     = ""
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

variable "atlantis_storage_class" {
  type        = string
  description = "Storage class to use for persistent volume"
  default     = "csi-gp3"
}

variable "atlantis_data_storage" {
  type        = string
  description = "Size of the persistent volume"
  default     = "5Gi"
}

# --------------------------------------------------
# Atlantis variables
# --------------------------------------------------
# Used as env variables within the Atlantis process.

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

variable "atlantis_resources_limits_cpu" {
  type        = string
  default     = null
  description = "CPU resources limits size"
}

variable "atlantis_resources_limits_memory" {
  type        = string
  default     = null
  description = "Memory resources limits size"
}

# --------------------------------------------------
# Atlantis
# --------------------------------------------------

variable "atlantis_add_secret_volumes" {
  type        = bool
  default     = false
  description = "Add secret volumes to the Atlantis deployment"

}

# --------------------------------------------------
# Traefik v2 through Flux CD
# --------------------------------------------------

# Using the variant variables one can perform a blue/green update on Traefik,
# routing traffic gradually to a new version and then decomissioning an older
# version without downtime.

variable "traefik_blue_variant_helm_chart_version" {
  type        = string
  description = "Helm Chart version to be used to deploy Traefik"
  default     = ""
}

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

variable "traefik_blue_variant_additional_args" {
  type        = list(any)
  description = "Pass arguments to the additionalArguments node in the Traefik Helm chart"
  default     = ["--metrics.prometheus"]
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

variable "traefik_green_variant_helm_chart_version" {
  type        = string
  description = "Helm Chart version to be used to deploy the Traefik green variant"
  default     = ""
}

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

variable "traefik_green_variant_additional_args" {
  type        = list(any)
  description = "Pass arguments to the additionalArguments node in the Traefik Helm chart for the green variant"
  default     = ["--metrics.prometheus"]
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
  default     = ""
}

variable "blackbox_exporter_monitoring_targets" {
  type        = list(object({ name = string, url = string, module = string }))
  description = "Complex object of what to monitor with Blackbox Exporter"
  default     = []
}

variable "blackbox_exporter_namespace" {
  type        = string
  description = "Namespace for blackbox exporter"
  default     = "monitoring"
}

variable "blackbox_exporter_monitoring_traefik_blue_variant_port" {
  type        = number
  description = "Port to monitor for the blue variant of Traefik"
  default     = 8080
}

variable "blackbox_exporter_monitoring_traefik_green_variant_port" {
  type        = number
  description = "Port to monitor for the green variant of Traefik"
  default     = 8080
}

# --------------------------------------------------
# Podinfo through Flux CD
# --------------------------------------------------

variable "podinfo_deploy" {
  type    = bool
  default = false
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
  default     = "v1.14.1"
  description = "The version of velero-plugin-for-aws to use as initContainer"
  validation {
    condition     = can(regex("^v(\\d+\\.\\d+)(\\.\\d+)?(-rc\\.\\d+|-beta\\.\\d+)?$", var.velero_plugin_for_aws_version)) || var.velero_plugin_for_aws_version == ""
    error_message = "Velero plugin for AWS must specify a version. The version must start with the letter v and followed by a semantic version number."
  }
}

variable "velero_snapshots_enabled" {
  type        = bool
  default     = false
  description = "Should Velero create snapshot on backups?"
}

variable "velero_filesystem_backup_enabled" {
  type        = bool
  default     = false
  description = "Should Velero have filesystem backups enabled?"
}

variable "velero_service_account" {
  type        = string
  default     = "velero-server"
  description = "The service account to be used by Velero"
}

variable "velero_namespace" {
  type        = string
  default     = "velero"
  description = "The namespace where Velero should be installed"
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


# --------------------------------------------------
# Subnet Exporter
# --------------------------------------------------
variable "subnet_exporter_deploy" {
  type        = bool
  default     = true
  description = "Feature toggle for Subnet Exporter module"
}

variable "subnet_exporter_iam_role_name" {
  type        = string
  default     = null
  description = "The IAM role name used for the AWS Subnet Exporter"
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

variable "grafana_agent_chart_version" {
  type        = string
  description = "Grafana Agent helm chart version"
  default     = ""
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

variable "grafana_agent_storage_enabled" {
  type        = bool
  default     = false
  description = "Enable persistence for Write Ahead Logs (WAL) in Grafana using Persistent Volume Claims"
}

variable "grafana_agent_storage_class" {
  type        = string
  description = "Storage class for Grafana Persistent Volume"
  default     = "csi-gp3"
}

variable "grafana_agent_storage_size" {
  type        = string
  description = "Storage size for Grafana Persistent Volume"
  default     = "5Gi"
}

variable "grafana_agent_namespace" {
  type        = string
  description = "Namespace for hosting monitoring components"
  default     = "grafana"
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
# External Secrets
# --------------------------------------------------

variable "external_secrets_deploy" {
  type        = string
  default     = false
  description = "Feature toggle for External Secrets module"
}

variable "external_secrets_helm_chart_version" {
  type        = string
  description = "External Secrets helm chart version"
  default     = ""
}

# --------------------------------------------------
# External Secrets with SSM
# --------------------------------------------------

variable "external_secrets_ssm_deploy" {
  type        = string
  default     = false
  description = "Feature toggle for External Secrets module"
}

variable "external_secrets_ssm_iam_role_name" {
  type        = string
  description = "The name of the IAM role to assume"
  default     = "ssm-secrets-for-kubernetes"
}

variable "external_secrets_ssm_service_account" {
  type        = string
  default     = "ssm-secrets"
  description = "The service account to be used by an SecretStore"
}

variable "external_secrets_ssm_allowed_namespaces" {
  type        = list(string)
  default     = []
  description = "The namespaces that can use IRSA to access external secrets"
}

variable "external_secrets_ssm_aws_region" {
  type        = string
  default     = ""
  description = "The AWS region to use for the external secrets"
}

# --------------------------------------------------
# External DNS
# --------------------------------------------------

variable "external_dns_deploy" {
  type        = string
  default     = false
  description = "Feature toggle for External DNS module"
}

variable "external_dns_helm_chart_version" {
  type        = string
  description = "External DNS helm chart version"
  default     = ""
}

variable "external_dns_domain_filters" {
  type        = list(string)
  description = "List of domain filters for External DNS"
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

variable "external_dns_domain_filterss" {
  type        = list(string)
  description = "List of domain filters for External DNS"
  default     = []
}

variable "external_dns_is_debug_mode" {
  type        = bool
  description = "Enable debug logging for External DNS"
  default     = false
}

variable "external_dns_core_account_route53_assume_role_arn" {
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

variable "onepassword_connect_chart_version" {
  type        = string
  default     = ""
  description = "The 1Password Connect helm chart version"
}

# --------------------------------------------------
# Nvidia device plugin
# --------------------------------------------------

variable "deploy_nvidia_device_plugin" {
  type        = bool
  default     = false
  description = "Whether to deploy NVIDIA device plugin. This needs to be set to `true` when GPU based workloads needs to be enabled."
}

variable "nvidia_chart_version" {
  type        = string
  description = "Nvidia device plugin helm chart version"
  default     = ""
}

variable "nvidia_namespace" {
  type        = string
  description = "Nvidia device plugin namespace"
  default     = "nvidia-device-plugin"
}

variable "nvidia_device_plugin_tolerations" {
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = string
  }))
  description = "A list of tolerations to apply to the nvidia device plugin deployment"
  default     = []
}

variable "nvidia_device_plugin_affinity" {
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  description = "A list of affinities to apply to the nvidia device plugin deployment"
  default     = []
}

# --------------------------------------------------
# Github ARC SS Controller
# --------------------------------------------------

variable "github_arc_ss_controller_deploy" {
  type        = string
  default     = false
  description = "Feature toggle for Github ARC SS Controller"
}

variable "github_arc_ss_controller_helm_chart_version" {
  type        = string
  description = "Github ARC SS Controller helm chart version"
  default     = ""
}

# --------------------------------------------------
# Github ARC Runners
# --------------------------------------------------

variable "github_arc_runners_deploy" {
  type        = string
  default     = false
  description = "Feature toggle for Github ARC Runners"
}

variable "github_arc_runners_helm_chart_version" {
  type        = string
  description = "Github ARC Runners helm chart version"
  default     = ""
}

variable "github_arc_runners_github_config_url" {
  type        = string
  description = "URL of Github organisation or repo for the runners"
  default     = ""
}

variable "github_arc_runners_github_config_secret" {
  type        = string
  description = "Secret name containing authorisation information for the runners. This is not deployed by this module, consider using external-secrets to deploy it"
  default     = ""
}

variable "github_arc_runners_runner_scale_set_name" {
  type        = string
  description = "Name for the runner scale set"
  default     = ""
}

variable "github_arc_runners_storage_class_name" {
  type        = string
  description = "Name of the storage class to use for the runners persistent volume"
  default     = "csi-gp3"
}

variable "github_arc_runners_storage_request_size" {
  type        = string
  description = "Size of the persistent volume claim for the runners"
  default     = "1Gi"
}

variable "github_arc_runners_min_runners" {
  type        = number
  description = "Minimum number of runners to keep running"
  default     = 0
}

variable "github_arc_runners_max_runners" {
  type        = number
  description = "Maximum number of runners to scale to"
  default     = 5
}

# --------------------------------------------------
# Apache Druid Operator
# --------------------------------------------------

variable "druid_operator_deploy" {
  type        = bool
  description = "Deploy druid_operator helm chart switch"
  default     = false
}

variable "druid_operator_deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "druid-operator"
}

variable "druid_operator_chart_version" {
  type        = string
  description = "Druid Operator helm chart version"
  default     = ""
}

variable "druid_operator_namespace" {
  type        = string
  description = "The namespace to deploy druid_operator in"
  default     = "druid-system"
}

variable "druid_operator_watch_namespace" {
  type        = string
  description = "Comma seperated string of namespaces to watch for Druid resources"
  default     = ""
}

variable "druid_operator_resources_requests_cpu" {
  type        = string
  default     = "10m"
  description = "CPU resources request size"
}

variable "druid_operator_resources_requests_memory" {
  type        = string
  default     = "128Mi"
  description = "Memory resources requests size"
}

variable "druid_operator_resources_limits_cpu" {
  type        = string
  default     = null
  description = "CPU resources limits size"
}

variable "druid_operator_resources_limits_memory" {
  type        = string
  default     = null
  description = "Memory resources limits size"
}

# --------------------------------------------------
# Trivy Operator
# --------------------------------------------------

variable "trivy_operator_deploy" {
  type        = bool
  description = "Deploy Trivy Operator helm chart switch"
  default     = false
}

variable "trivy_operator_deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "trivy-operator"
}

variable "trivy_operator_chart_version" {
  type        = string
  description = "Trivy Operator helm chart version"
  default     = ""
}

variable "trivy_operator_namespace" {
  type        = string
  description = "The namespace to deploy Trivy Operator in"
  default     = "trivy-system"
}

variable "trivy_operator_resources_requests_cpu" {
  type        = string
  default     = "100m"
  description = "CPU resources request size"
}

variable "trivy_operator_resources_requests_memory" {
  type        = string
  default     = "128Mi"
  description = "Memory resources requests size"
}

variable "trivy_operator_resources_limits_cpu" {
  type        = string
  default     = "500m"
  description = "CPU resources limits size"
}

variable "trivy_operator_resources_limits_memory" {
  type        = string
  default     = "1024Mi"
  description = "Memory resources limits size"
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

variable "falco_chart_version" {
  type        = string
  description = "Falco helm chart version"
  default     = ""
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
  default     = false
}

variable "keda_deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "keda"
}

variable "keda_chart_version" {
  type        = string
  description = "KEDA helm chart version"
  default     = ""
}

variable "keda_namespace" {
  type        = string
  description = "The namespace to deploy KEDA in"
  default     = "keda"
}
