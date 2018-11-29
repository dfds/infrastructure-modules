#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file

variable "aws_region" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "assume_role_arn" {
  type = "string"
}
