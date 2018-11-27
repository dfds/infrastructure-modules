#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file

variable "aws_region" {
  type = "string"
}
variable "user_pool_name" {
  type = "string"
}

variable "user_pool_domain_name" {
  type = "string"
}
variable "user_pool_client_name" {
    type = "string"
}


variable "user_pool_identity_provider_name" {
    type = "string"
}
variable "build_callback_url" {
  type = "string"  
}

variable "build_logout_url" {
  type = "string"
}

variable "azure_ad_tenant_id" {
  type = "string"  
}

