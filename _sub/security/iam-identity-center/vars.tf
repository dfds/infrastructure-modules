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
