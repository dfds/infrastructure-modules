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

# --------------------------------------------------
# EKS
# --------------------------------------------------

variable "eks_cluster_name" {
  type = string
}


# --------------------------------------------------
# KIAM
# --------------------------------------------------

variable "kiam_deploy" {
  default = false
}

variable "kiam_chart_version" {
  type        = string
  description = "KIAM helm chart version"
  default     = null
}


# --------------------------------------------------
# FluentD CloudWatch Logs
# --------------------------------------------------

variable "aws_assume_logs_role_arn" {
  type    = string
  default = ""
}

variable "cloudwatchlogs_iam_role_deploy" {
  type        = bool
  default     = false
  description = "Deploy an AWS IAM role for FluentD to assume, to enabling shipping logs to CloudWatch Logs"
}


# --------------------------------------------------
# Traefik
# --------------------------------------------------

variable "traefik_deploy" {
  type    = bool
  default = false
}

variable "traefik_version" {
  type    = string
  default = "1.7.19"
}

variable "traefik_http_nodeport" {
  type    = number
  default = 30000
}

variable "traefik_admin_nodeport" {
  type    = number
  default = 30001
}

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

variable "blaster_configmap_deploy" {
  type    = bool
  default = false
}

variable "traefik_health_check_path" {
  type    = string
  default = "/dashboard/"
}


# --------------------------------------------------
# Traefik Okta
# --------------------------------------------------

variable "traefik_okta_deploy" {
  type    = bool
  default = false
}

variable "traefik_okta_version" {
  type    = string
  default = ""
}

variable "traefik_alb_okta_deploy" {
  type    = bool
  default = false
}

variable "traefik_alb_okta_core_alias" {
  description = "A list of aliases/alternative names in the *parent* domain, the certficate should also be valid for. E.g. 'prettyurl.company.tld'"
  type        = list(string)
  default     = []
}

variable "traefik_okta_http_nodeport" {
  type    = number
  default = 31000
}

variable "traefik_okta_admin_nodeport" {
  type    = number
  default = 31001
}

variable "traefik_okta_health_check_path" {
  type    = string
  default = "/ping/"
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
  default     = false
}

variable "monitoring_namespace_iam_roles" {
  type        = string
  description = "IAM roles allowed to assume"
  default     = ""
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
  default     = "HelloWorld"
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

variable "monitoring_kube_prometheus_stack_slack_webhook" {
  type        = string
  description = "Kube-prometheus-stack alert slack webhook"
  default     = ""
}

variable "monitoring_kube_prometheus_stack_prometheus_storageclass" {
  type        = string
  description = "Prometheus storage class"
  default     = "gp2"
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

variable "monitoring_alertmanager_silence_namespaces" {
  type        = string
  description = "Silence noisy namespaces via alertmanager"
  default     = ""
}

# --------------------------------------------------
# Metrics-Server
# --------------------------------------------------

variable "monitoring_metrics_server_deploy" {
  type        = bool
  description = "Deploy metrics-server helm chart switch. If setting to true, monitoring_namespace_deploy must also be set to true"
  default     = false
}

variable "monitoring_metrics_server_chart_version" {
  type        = string
  description = "metrics-server helm chart version"
  default     = null
}

variable "monitoring_metrics_server_chart_namespace" {
  type        = string
  description = "Namespace to apply metrics-server in"
  default     = "monitoring"
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
# AWS EBS CSI Driver
# --------------------------------------------------

variable "ebs_csi_driver_deploy" {
  type        = bool
  description = "Deploy AWS EBS CSI driver Helm chart"
  default     = false
}

variable "ebs_csi_driver_chart_version" {
  type        = string
  description = "The version of the AWS EBS CSI driver Helm chart to deploy (defaults to latest)"
  default     = null
}


# --------------------------------------------------
# Platform Flux CD
# --------------------------------------------------

variable "platform_fluxcd_deploy" {
  type        = bool
  default     = false
  description = ""
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
  default     = ""
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

variable "github_token" {
  description = "Github token that the provider uses to perform Github operations. Leaving unset will fall back to GITHUB_TOKEN environment variable"
  default     = null
}

variable "github_organization" {
  description = "Github organization name. Conflicts with github_owner. Leaving unset will use GITHUB_ORGANIZATION environment variable if exists"
  default     = null
}

variable "github_owner" {
  description = "Github owner(username). Conflicts with github_organization. Leaving unset will use GITHUB_OWNER environment variable if exists"
  default     = null
}

variable "github_username" {
  description = "Github username of the account that will post Atlantis comments on PR's"
  default     = null
}

variable "github_repositories" {
  description = "List of repositories to whitelist for Atlantis"
  type        = list(string)
  default     = []
}

variable "webhook_secret" {
  description = "Secret used by the Webhook to speak to Atlantis"
  default     = null
}

variable "webhook_content_type" {
  default = "application/json"
}

variable "webhook_insecure_ssl" {
  default = false
}

variable "webhook_events" {
  description = "A list of events that should trigger the webhook"
  default     = []
  type        = list(string)
}

variable "namespace" {
  type        = string
  description = ""
  default     = "atlantis"
}

variable "chart_version" {
  type        = string
  description = ""
  default     = null
}

variable "atlantis_ingress" {
  type        = string
  description = ""
  default     = null
}

variable "atlantis_image" {
  type        = string
  description = ""
  default     = "dfdsdk/atlantis-prime-pipeline"
}

variable "atlantis_image_tag" {
  type        = string
  description = "Tag of the Atlantis image to use"
  default     = "latest"
}

variable "arm_tenant_id" {
  type        = string
  description = ""
  default     = null
}

variable "arm_subscription_id" {
  type        = string
  description = ""
  default     = null
}

variable "arm_client_id" {
  type        = string
  description = ""
  default     = null
}

variable "arm_client_secret" {
  type        = string
  description = ""
  default     = null
}

variable "aws_access_key" {
  description = "AWS Access Key"
  default     = null
}

variable "aws_secret" {
  description = "AWS Secret"
  default     = null
}

variable "access_key_master" {
  type        = string
  description = "Access Key for Core account"
  default     = null
}

variable "secret_key_master" {
  type        = string
  description = "Secret for Core account"
  default     = null
}

# --------------------------------------------------
# Crossplane
# --------------------------------------------------

variable "crossplane_deploy" {
  type = bool
  description = "Deploy Crossplane"
  default = false
}

variable "crossplane_namespace" {
  type = string
  description = "Namespace in which to install Crossplane"
}

variable "crossplane_release_name" {
  type = string
  description = "Name of the chart release"
}

variable "crossplane_chart_version" {
  type = string
  description = "Specify a version of the Helm chart"
}

variable "crossplane_recreate_pods" {
    type = bool
    description = "Recreate pods on deployment"
}

variable "crossplane_force_update" {
    type = bool
    description = "Force resource updates through replacement"
}

variable "crossplane_providers" {
  type = list(string)
  description = "List of Crossplane providers to install"
}