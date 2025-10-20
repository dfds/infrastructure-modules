variable "github_owner" {
  type = string
  default = "dfds"
}

variable "github_repository" {
  type        = string
  default     = "platform-apps"
  description = "The https url for your GitOps manifests"
}

variable "github_branch" {
  type        = string
  default     = "main"
  description = "The default branch for your GitOps manifests"
}

variable "overlay_path" {
  type        = string
  description = "Override the default kustomizations path"
  default     = ""
}

variable "cluster_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}