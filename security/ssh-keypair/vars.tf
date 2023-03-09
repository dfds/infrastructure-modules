# --------------------------------------------------
# AWS
# --------------------------------------------------
variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "keypairname" {
  type        = string
  description = "Name the Keypair will be saved as in AWS Parameter Store"
}

variable "deploy" {
  type    = bool
  default = true
}
