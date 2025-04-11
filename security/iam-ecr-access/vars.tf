variable "aws_region" {
  type = string
}

variable "aws_workload_account_id" {
  description = "The ID of the account trusted to assume the role"
  type        = string
}

variable "prime_role_name" {
  type    = string
  default = ""
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

variable "fluxcd_role_name" {
  description = "IAM role for ECR access from FluxCD source controller"
  type        = string
  default     = "fluxcd-source-controller-ecr-reader"
}

variable "fluxcd_role_prod_trust" {
  description = "A map of the trust relationship for the IAM role. Mandatory."
  type = map(object({
    oidc_fqdn_url      = optional(string, "")
    action             = optional(string, "sts:AssumeRoleWithWebIdentity")
    effect             = optional(string, "Allow")
    condition_operator = optional(string, "StringEquals")
    condition_variable = optional(string, "sub")
    condition_values   = optional(string, "system:serviceaccount:flux-system:source-controller")
  }))
}

variable "fluxcd_role_nonprod_trust" {
  description = "A map of the trust relationship for the IAM role. Optional."
  type = map(object({
    oidc_fqdn_url      = optional(string, "")
    action             = optional(string, "sts:AssumeRoleWithWebIdentity")
    effect             = optional(string, "Allow")
    condition_operator = optional(string, "StringEquals")
    condition_variable = optional(string, "sub")
    condition_values   = optional(string, "system:serviceaccount:flux-system:source-controller")
  }))
  default = {}
}
