# # --------------------------------------------------
# # Terraform
# # --------------------------------------------------

# variable "terraform_state_s3_bucket" {
#   type = "string"
# }

# --------------------------------------------------
# AWS
# --------------------------------------------------

variable "aws_region" {
  type = "string"
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "cdn_origins" {
  type = "list"
}

variable "cdn_comment" {
  type = "string"
}

variable "acm_certificate_arn" {
  default = ""
}

variable "cdn_domain_name" {
  default = ""
  type = "string"
}