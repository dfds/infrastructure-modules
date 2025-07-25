#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = string
}

variable "aws_region_2" {
  type        = string
  description = "Terraform has limitations that prevent us from dynamically creating AWS providers for each region, so instead of providing a list of regions we will specifiy an incremented set of variables to deploy resources across multiple regions."
}

variable "master_account_id" {
  type        = string
  description = "The AWS account ID of the Organizations Master account"
}

variable "security_account_id" {
  type        = string
  description = "The AWS account ID of the Organizations Security account"
}

variable "access_key_master" {
  type = string
}

variable "secret_key_master" {
  type = string
}

variable "aws_session_name" {
  type        = string
  description = "An identifier for the AWS session name. This can be useful in identifiying which pipeline executed the Terraform."
  default     = null
}

variable "name" {
  type = string
}

variable "org_role_name" {
  type = string
}

variable "prime_role_name" {
  type = string
}

variable "prime_role_max_session_duration" {
  type    = string
  default = 7200 # 2 hours
}

variable "email" {
  type = string
}

variable "primary_phone_number" {
  type = string
}

variable "email_security" {
  type    = string
  default = null
}

variable "cloudtrail_local_s3_bucket" {
  type    = string
  default = ""
}

variable "parent_id" {
  type        = string
  description = "The ID of the parent AWS Organization OU. Defaults to the root."
  default     = "r-65k1"
}

variable "aws_region_sso" {
  type    = string
  default = "eu-west-1"
}

variable "sso_admin_permission_set_name" {
  type = string
}

variable "sso_admin_group_name" {
  type = string
}

variable "sso_IAMRA_permission_set_name" {
  type    = string
  default = ""
}

variable "sso_IAMRA_group_name" {
  type    = string
  default = ""
}

variable "sso_support_permission_set_name" {
  type    = string
  default = null
}

variable "sso_support_group_name" {
  type    = string
  default = null
}

variable "sso_netsec_mgmt_permission_set_name" {
  type        = string
  description = "The name of the IAM Identity Center permission set for the Network Security Management group."
  default     = ""
}

variable "sso_netsec_mgmt_group_name" {
  type        = string
  description = "The name of the IAM Identity Center group for the Network Security Management group."
  default     = ""
}

variable "harden" {
  type    = bool
  default = false
}

variable "security_bot_lambda_version" {
  type = string
}

variable "security_bot_lambda_s3_bucket" {
  type        = string
  description = "The S3 bucket where the Security Bot Lambda package is stored."
}

variable "hardened_monitoring_email" {
  type    = string
  default = null
}

variable "hardened_monitoring_slack_channel" {
  type    = string
  default = null
}

variable "hardened_monitoring_slack_token" {
  type      = string
  sensitive = true
  default   = null
}

variable "hardened_enable_default_standards" {
  type    = bool
  default = false
}

variable "hardened_kms_primary_key_arn" {
  type    = string
  default = null
}

variable "hardened_kms_replica_key_arn" {
  type    = string
  default = null
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

# --------------------------------------------------
# IAM role for Grafana Cloud Cloudwatch integration
# --------------------------------------------------

variable "grafana_cloud_cloudwatch_integration_iam_role" {
  type = object({
    arn       = string
    stack_ids = list(string)
  })
  description = "IAM role used for Grafana Cloud IAM CloudWatch access"
  default     = null
}

# --------------------------------------------------
# Steampipe
# --------------------------------------------------

variable "steampipe_audit_role_name" {
  type        = string
  description = "Name of the IAM role used by Steampipe for reading resources"
  default     = "steampipe-audit"
}
