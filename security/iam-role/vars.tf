variable "aws_region" {
  type = string
}

variable "role_name" {
  type = string
}

variable "custom_policies" {
  description = "A map of custom IAM policies to create"
  type = map(object({
    policy = object({
      Version = optional(string, "2012-10-17")
      Statement = list(object({
        Sid      = optional(string)
        Effect   = string
        Action   = list(string)
        Resource = list(string)
      }))
    })
  }))
  default = {}
}

variable "trust_policy_permissions" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom trust policy permissions"
  type = map(object({
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = optional(string, "Allow")
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })))
  }))
  default = null
}

variable "existing_policies" {
  description = "A map of policy ARNs for AWS managed policies or existing custom policies"
  type        = map(string)
  default     = {}
}

variable "enable_github_oidc" {
  type        = bool
  description = "Whether to include the GitHub OIDC trust relationship in the role's trust policy"
  default     = false
}

variable "oidc_wildcard_subjects" {
  description = "The OIDC subject using wildcards to be added to the role policy"
  type        = list(string)
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}
