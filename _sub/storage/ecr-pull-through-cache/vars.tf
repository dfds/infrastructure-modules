
variable "username" {
  type        = string
  sensitive   = true
  description = "Username for pulling images from Docker Hub or GitHub Container Registry."
  default     = ""
}

variable "token" {
  type        = string
  sensitive   = true
  description = "Access token for pulling images from Docker Hub or GitHub Container Registry."
  default     = ""
}

variable "aws_org_id" {
  type        = string
  description = "AWS Organization ID for policy to grant access to ECR pull-through cache."
  validation {
    condition     = can(regex("^o-[0-9a-z]{10,11}$", var.aws_org_id))
    error_message = "AWS Organization ID must be a 12-character string starting with o-."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region where the ECR pull-through cache will be created."
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format 'eu-central-1', 'eu-west-1', etc."
  }
}

variable "secret_name" {
  type        = string
  description = "Name of the AWS Secrets Manager secret for Docker Hub or GitHub Container Registry credentials."
}

variable "recovery_window_in_days" {
  type        = number
  description = "Number of days to retain the secret before deletion."
  default     = 30
}

variable "ecr_repository_prefix" {
  type        = string
  description = "Prefix for ECR repositories used in pull-through cache."
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.ecr_repository_prefix))
    error_message = "ECR repository prefix must be a valid DNS label."
  }
}

variable "upstream_registry_url" {
  type        = string
  description = "URL of the upstream registry for pull-through cache."
}

variable "cache_lifecycle_days" {
  type        = number
  description = "Number of days after which cached images will be expired."
  default     = 7
  validation {
    condition     = var.cache_lifecycle_days > 0
    error_message = "Cache lifecycle days must be greater than zero."
  }
}
