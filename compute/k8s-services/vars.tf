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
  default = null
}

variable "cloudwatchlogs_iam_role_deploy" {
  type        = bool
  default     = false
  description = "Deploy an AWS IAM role for FluentD to assume, to enabling shipping logs to CloudWatch Logs"
}

# --------------------------------------------------
# ALB access logs S3 bucket
# --------------------------------------------------

variable "traefik_alb_s3_access_logs_retiontion_days" {
  type    = number
  default = 30
}

# --------------------------------------------------
# Traefik
# --------------------------------------------------

variable "traefik_deploy" {
  type    = bool
  default = true
}

variable "traefik_version" {
  type    = string
  default = "1.7"
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

variable "traefik_dashboard_deploy" {
  type        = bool
  description = "Deploy ingress for secure access to Traefik dashboard."
  default     = true
}


# --------------------------------------------------
# Traefikv2
# --------------------------------------------------
variable "traefikv2_test_alb_deploy" {
  type    = bool
  default = false
}

variable "traefikv2_http_nodeport" {
  type    = number
  default = 31000
}

variable "traefikv2_admin_nodeport" {
  type    = number
  default = 31001
}

variable "traefikv2_health_check_path" {
  type    = string
  default = "/dashboard/"
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
  default     = ""
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
  default     = true
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
  default     = ""
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
  default     = ""
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
  default     = ""
}

variable "atlantis_arm_subscription_id" {
  type        = string
  description = "Used to set environment variable for ARM subscription ID"
  default     = ""
}

variable "atlantis_arm_client_id" {
  type        = string
  description = "Used to set environment variable for ARM client ID"
  default     = ""
}

variable "atlantis_arm_client_secret" {
  type        = string
  description = "Used to set environment variable for ARM client secret"
  default     = ""
}

variable "atlantis_aws_access_key" {
  description = "AWS Access Key"
  default     = ""
}

variable "atlantis_aws_secret" {
  description = "AWS Secret"
  default     = ""
}

variable "atlantis_access_key_master" {
  type        = string
  description = "Access Key for Core account"
  default     = ""
}

variable "atlantis_secret_key_master" {
  type        = string
  description = "Secret for Core account"
  default     = ""
}

variable "atlantis_storage_class" {
  type        = string
  description = "Storage class to use for persistent volume"
  default     = "csi-gp2"
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
  default     = "crossplane-system"
}

variable "crossplane_release_name" {
  type        = string
  description = "Name of the chart release"
  default     = "crossplane"
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
  type        = list
  description = "Pass arguments to the additionalArguments node in the Traefik Helm chart"
  default     = ["--metrics.prometheus"]
}

variable "traefik_fallback_enabled" {
  type        = bool
  description = "Should a fallback ingressroute be created that routes traffic to Traefik v1"
  default     = false
}

variable "traefik_fallback_ingressroute_priority" {
  type        = number
  description = "IngressRoute priority. Should be a low number, but preferably not lower than 2"
  default     = 2
}

variable "traefik_fallback_rule_match" {
  type        = string
  description = "The rule match of hosts, regexp and/or paths to serve through a fallback ingressroute"
  default     = "HostRegexp(`{domain:.+}`)"
}

variable "traefik_fallback_ingressroute_name" {
  type        = string
  description = "The name for the ingressroute used for fallback"
  default     = "traefik-fallback-to-v1-ingress"
}

variable "traefik_fallback_svc_namespace" {
  type        = string
  description = "The service used for fallback ingress is stored in which namespace"
  default     = "kube-system"
}

variable "traefik_fallback_svc_name" {
  type        = string
  description = "The service name used for fallback ingress"
  default     = "traefik"
}

variable "traefik_fallback_svc_port" {
  type        = number
  description = "The service port used for fallback ingress"
  default     = 80
}

variable "traefik_flux_deploy" {
  type    = bool
  default = true
}
