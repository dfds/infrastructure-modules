# --------------------------------------------------
# AWS
# --------------------------------------------------

variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

# --------------------------------------------------
# EKS
# --------------------------------------------------

variable "eks_cluster_name" {
  type = string
}

# --------------------------------------------------
# Unused variables - to provent TF warning/error:
# Using a variables file to set an undeclared variable is deprecated and will
# become an error in a future release. If you wish to provide certain "global"
# settings to all configurations in your organization, use TF_VAR_...
# environment variables to set these instead.
# --------------------------------------------------

variable "aws_workload_account_id" {
  type = string
  default = ""
}

variable "workload_dns_zone_name" {
  type    = string
  default = ""
}

# variable "azure_tenant_id" {
#   type    = string
#   default = ""
# }

variable "terraform_state_s3_bucket" {
  type    = string
  default = ""
}

variable "terraform_state_region" {
  type    = string
  default = ""
}

variable "eks_public_s3_bucket" {
  type    = string
  default = ""
}


/*
aws_workload_account_id = "944250853760"
aws_assume_role_arn = "arn:aws:iam::944250853760:role/EksAdmin" # arn:aws:iam::738063116313:role/Prime = Prime role in Oxygen account
workload_dns_zone_name = "raras.dfds.cloud"
azure_tenant_id = "73a99466-ad05-4221-9f90-e7142aa2f6c1"
terraform_state_s3_bucket  = "raras-sandbox-state"
terraform_state_region = "eu-central-1"
*/