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

variable "traefik_deploy_name" {
}

variable "traefik_alb_anon_deploy" {
  type    = bool
  default = false
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

# --------------------------------------------------
# Cloudwatch ALB 500 errors alerts to slack
# --------------------------------------------------

variable "cwalarms_alb_500_deploy" {
  type    = bool
  default = false
}

variable "cwalarms_alb_500_slack_hook" {
  type    = string
  default = ""
}

variable "cwalarms_alb_500_slack_channel" {
  type    = string
  default = ""
}


# --------------------------------------------------
# KIAM
# --------------------------------------------------

variable "kiam_deploy" {
  default = false
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
