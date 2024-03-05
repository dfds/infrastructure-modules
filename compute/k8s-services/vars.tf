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

# Optional
# --------------------------------------------------

variable "s3_bucket_additional_tags" {
  description = "Add additional tags to s3 bucket"
  type        = map(any)
  default     = {}
}

# --------------------------------------------------
# EKS
# --------------------------------------------------

variable "eks_cluster_name" {
  type = string
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

variable "staging_slack_webhook_url" {
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

variable "monitoring_goldpinger_deploy" {
  type        = bool
  description = "Deploy goldpinger helm chart switch"
  default     = false
}

variable "monitoring_goldpinger_chart_version" {
  type        = string
  description = "Goldpinger helm chart version"
  default     = "6.0.1"
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

variable "monitoring_kube_prometheus_stack_grafana_serviceaccount_name" {
  type        = string
  description = "Grafana serviceaccount to be used for pod"
  default     = "grafana-cloudwatch"
}

variable "monitoring_kube_prometheus_stack_grafana_storage_enabled" {
  type        = bool
  description = "Enable persistence in Grafana using Persistent Volume Claims"
  default     = false
}

variable "monitoring_kube_prometheus_stack_grafana_storageclass" {
  type        = string
  description = "Storage class for Grafana Persistent Volume"
  default     = "csi-gp2"
}

variable "monitoring_kube_prometheus_stack_grafana_storage_size" {
  type        = string
  description = "Storage size for Grafana Persistent Volume"
  default     = ""
}

variable "monitoring_kube_prometheus_stack_grafana_serve_from_sub_path" {
  type        = bool
  default     = false
  description = "Serve Grafana from subpath specified in root_url setting. By default it is set to false for compatibility reasons"
}

variable "monitoring_kube_prometheus_stack_azure_tenant_id" {
  type        = string
  default     = ""
  description = "Azure Tenant ID"
}

variable "monitoring_kube_prometheus_stack_slack_webhook" {
  type        = string
  description = "Kube-prometheus-stack alert slack webhook"
  default     = ""
}

variable "monitoring_kube_prometheus_stack_staging_slack_webhook" {
  type        = string
  description = "Kube-prometheus-stack alert slack webhook for the staging environment"
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

variable "monitoring_kube_prometheus_stack_prometheus_query_log_file_enabled" {
  type        = bool
  description = "Whether to enable the query logging in Prometheus."
  default     = false
}

variable "monitoring_kube_prometheus_stack_prometheus_enable_features" {
  type        = list(string)
  description = "Prometheus feature flags to enable."
  default     = []
}

variable "monitoring_kube_prometheus_stack_prometheus_confluent_metrics_scrape_enabled" {
  type        = string
  description = "Whether to enable scraping of Confluent metrics in Prometheus."
  default     = false
}
variable "monitoring_kube_prometheus_stack_prometheus_confluent_metrics_api_key" {
  type        = string
  description = "Confluent metrics API key."
  default     = null
}

variable "monitoring_kube_prometheus_stack_prometheus_confluent_metrics_api_secret" {
  type        = string
  description = "Confluent metrics API secret."
  default     = null
}

variable "monitoring_kube_prometheus_stack_prometheus_confluent_metrics_scrape_interval" {
  type        = string
  description = "Confluent metrics scrape interval."
  default     = "1m"
}

variable "monitoring_kube_prometheus_stack_prometheus_confluent_metrics_scrape_timeout" {
  type        = string
  description = "Confluent metrics scrape timeout."
  default     = "1m"
}

variable "monitoring_kube_prometheus_stack_prometheus_confluent_metrics_resource_kafka_id_list" {
  type        = list(string)
  description = "List of Kafka cluster IDs to scrape metrics from"
  default     = []
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
  default     = []
  type        = list(string)
}

variable "atlantis_namespace" {
  type        = string
  description = "Namespace for Atlantis deployment"
  default     = "atlantis"
}

variable "atlantis_namespace_labels" {
  type    = map(any)
  default = { "pod-security.kubernetes.io/audit" = "baseline", "pod-security.kubernetes.io/warn" = "baseline" }
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

variable "atlantis_environment" {
  type        = string
  description = "Environment for atlantis"
  default     = ""
}

# --------------------------------------------------
# Atlantis variables
# --------------------------------------------------
# Used as env variables within the Atlantis process.

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
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "AWS Access Key"
}

variable "atlantis_aws_secret" {
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "AWS Secret"
}

variable "prime_aws_access_key" {
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "AWS Access Key for prime pipeline. Used by Atlantis."
}

variable "prime_aws_secret" {
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "AWS Secret for prime pipeline. Used by Atlantis."
}

variable "preprime_aws_access_key" {
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "AWS Access Key for pre-prime pipeline. Used by Atlantis."
}

variable "preprime_aws_secret" {
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "AWS Secret for pre-prime pipeline. Used by Atlantis."
}

variable "preprime_backup_reports_slack_webhook_url" {
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "Webhook token for backup reports used in pre-prime pipeline. Used by Atlantis."
}

variable "aws_account_manifests_kafka_broker" {
  type        = string
  default     = ""
  description = "Used by Atlantis for the AWS Account Manifests pipeline"
}

variable "aws_account_manifests_kafka_username" {
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "Used by Atlantis for the AWS Account Manifests pipeline"
}

variable "aws_account_manifests_kafka_password" {
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "Used by Atlantis for the AWS Account Manifests pipeline"
}

variable "aws_account_manifests_hardened_monitoring_slack_token" {
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "Used by Atlantis for the AWS Account Manifests pipeline"
}

variable "atlantis_staging_aws_access_key" {
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "AWS Access Key for staging environment"
}

variable "atlantis_staging_aws_secret" {
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "AWS Secret for staging environment"
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

variable "atlantis_grafana_cloud_api_key" {
  type        = string
  default     = "" #tfsec:ignore:general-secrets-sensitive-in-variable
  description = "Grafana Cloud API key"
  sensitive   = true
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

variable "crossplane_namespace_labels" {
  type    = map(any)
  default = { "pod-security.kubernetes.io/audit" = "baseline", "pod-security.kubernetes.io/warn" = "baseline" }
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

# --------------------------------------------------
# Traefik v2 through Flux CD
# --------------------------------------------------

# Using the variant variables one can perform a blue/green update on Traefik,
# routing traffic gradually to a new version and then decomissioning an older
# version without downtime.

variable "traefik_blue_variant_helm_chart_version" {
  type        = string
  description = "Helm Chart version to be used to deploy Traefik"
  default     = null
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
  default     = null
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
  default     = null
}

variable "blackbox_exporter_monitoring_targets" {
  type        = list(object({ name = string, url = string, module = string }))
  description = "Complex object of what to monitor with Blackbox Exporter"
  default     = []
}

# --------------------------------------------------
# Helm Exporter
# --------------------------------------------------

variable "helm_exporter_deploy" {
  type        = bool
  description = "Should the helm Exporter be deployed through Flux?"
  default     = false
}

variable "helm_exporter_helm_chart_version" {
  type        = string
  description = "Helm Chart version to be used to deploy Helm Exporter"
  default     = null
}

variable "helm_exporter_target_namespaces" {
  type        = string
  description = "target namespaces filter"
  default     = ""
}

variable "helm_exporter_target_charts" {
  type = list(object({
    registry = object({
      url = string
    })
    charts = list(string)
  }))
  default = []
}

# --------------------------------------------------
# Podinfo through Flux CD
# --------------------------------------------------

variable "podinfo_deploy" {
  type    = bool
  default = false
}

# --------------------------------------------------
# fluentd-cloudwatch through Flux
# --------------------------------------------------

variable "fluentd_cloudwatch_deploy" {
  type    = bool
  default = false
}

variable "fluentd_cloudwatch_retention_in_days" {
  type        = string
  default     = "7"
  description = "How many days to keep the logs?"
}

variable "fluentd_cloudwatch_docker_image_name" {
  type        = string
  default     = "fluent/fluentd-kubernetes-daemonset"
  description = "The repo/name for the fluentd-kubernetes-daemonset image"
}

variable "fluentd_cloudwatch_docker_image_tag" {
  type        = string
  default     = "v1.16-debian-cloudwatch-1"
  description = "The tag for the fluentd-kubernetes-daemonset image"
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

variable "velero_snapshots_enabled" {
  type        = bool
  default     = false
  description = "Should Velero create snapshot on backups?"
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


# --------------------------------------------------
# Kyverno
# --------------------------------------------------

variable "kyverno_chart_version" {
  type        = string
  default     = "v2.4.1"
  description = "Helm chart version of Kyverno"
}

variable "kyverno_deploy" {
  type        = string
  default     = false
  description = "Feature toggle for Kyverno module"
}

variable "kyverno_replicas" {
  type        = number
  default     = 3
  description = "Number of replica pods for Kyverno"
}

variable "kyverno_namespace_labels" {
  type    = map(any)
  default = { "pod-security.kubernetes.io/audit" = "baseline", "pod-security.kubernetes.io/enforce" = "privileged" }
}


# --------------------------------------------------
# Subnet Exporter
# --------------------------------------------------

variable "subnet_exporter_iam_role_name" {
  type        = string
  default     = null
  description = "The IAM role name used for the AWS Subnet Exporter"
}

# --------------------------------------------------
# Inactivity based clean up for sandboxes
# --------------------------------------------------

variable "disable_inactivity_cleanup" {
  type        = bool
  default     = false
  description = "Disables automated clean up of ELB resources based on inactivity. Only applicable to sandboxes."
}

# --------------------------------------------------
# Grafana Agent for Kubernetes monitoring
# --------------------------------------------------

variable "grafana_agent_deploy" {
  type        = string
  default     = false
  description = "Feature toggle for Grafana Agent module"
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

variable "staging_grafana_agent_api_token" {
  type        = string
  description = "The token to authenticate request to a Grafana Cloud stack"
  default     = ""
  sensitive   = true
}

variable "staging_grafana_agent_prometheus_url" {
  type        = string
  description = "The Prometheus URL in a Grafana Cloud stack"
  default     = ""
}

variable "staging_grafana_agent_prometheus_username" {
  type        = string
  description = "The username for Prometheus in a Grafana Cloud stack"
  default     = ""
}

variable "staging_grafana_agent_loki_url" {
  type        = string
  description = "The Loki URL in a Grafana Cloud stack"
  default     = ""
}

variable "staging_grafana_agent_loki_username" {
  type        = string
  description = "The username for Loki in a Grafana Cloud stack"
  default     = ""
}

variable "staging_grafana_agent_tempo_url" {
  type        = string
  description = "The Tempo URL in a Grafana Cloud stack"
  default     = ""
}

variable "staging_grafana_agent_tempo_username" {
  type        = string
  description = "The username for Tempo in a Grafana Cloud stack"
  default     = ""
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
