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
# KIAM
# --------------------------------------------------

variable "kiam_deploy" {
  default = false
}

variable "kiam_image_tag" {
  type        = string
  description = "Image tag of KIAM to deploy"
  default     = "v3.5"

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

# --------------------------------------------------
# Cloudwatch alarms and alarm notifier (Slack)
# --------------------------------------------------

variable "slack_webhook_url" {
  type    = string
  default = ""
}

variable "alarm_notifier_deploy" {
  type     = bool
  default = false
}

variable "cloudwatch_alarm_alb_targets_health_deploy" {
  type     = bool
  default = false
}

variable "cloudwatch_alarm_alb_5XX_deploy" {
  type     = bool
  default = false
}

# --------------------------------------------------
# Goldpinger
# --------------------------------------------------

variable "goldpinger_deploy" {
  type = bool
  description = "Deploy goldpinger helm chart switch"
  default = false
}

variable "goldpinger_chart_version" {
  type = string
  description = "Goldpinger helm chart version"
  default = null
}

variable "goldpinger_priority_class" {
  type = string
  description = "Goldpinger daemonset priority class name"
  default = "cluster-monitoring"
}