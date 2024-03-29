variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "bucket_name" {
  type        = string
  description = "Velero storage bucket name"
}

variable "force_bucket_destroy" {
  type        = bool
  default     = true
  description = "Destroy bucket without error"
}

variable "additional_tags" {
  description = "Add additional tags to s3 bucket"
  type        = map(any)
  default     = {}
}

variable "velero_role_arn" {
  description = "Which role arn can use the bucket?"
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

variable "data_tags" {
  type        = map(string)
  description = "A map of tags to apply to all the data and/or storage deployed by the module"
  default     = {}
}
