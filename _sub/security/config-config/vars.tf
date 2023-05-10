variable "deploy" {
  description = "Configure AWS Config feature toggle."
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 Bucket where AWS Config inventory and logs will be stored."
}

variable "s3_bucket_arn" {
  type        = string
  description = "The name of the S3 Bucket where AWS Config inventory and logs will be stored."
}

variable "conformance_packs" {
  type        = set(string)
  description = "The list of the AWS Config conformance packs that one would like to enable."
  default     = []
}
