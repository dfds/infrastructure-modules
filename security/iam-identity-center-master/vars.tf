variable "aws_region" {
  type = string
}

variable "pca_account_ids" {
  type        = list(string)
  description = "The list of account IDs where PCA is deployed"
  default     = []
}

variable "private_ca_arns" {
  type        = list(string)
  description = "The list of Private Certificate Authority ARNs"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}
