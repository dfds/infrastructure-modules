# --------------------------------------------------
# AWS
# --------------------------------------------------

variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "s3_app_bucket" {

}

variable "s3_app_allowed_iam_arns" {
  type = list
  default = []
}
