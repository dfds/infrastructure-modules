variable "aws_region" {
  type = string
}

variable "vpc_cidr_block" {
  default = "192.168.0.0/16"
}

variable "subnet_cidr_blocks" {
  default = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"]
}

variable "ad_name" {
  type        = string
  description = "The fully qualified name for the directory, such as corp.example.com"
}

variable "ad_password" {
  type        = string
  description = "The password for the directory administrator"
}

variable "ad_edition" {
  type        = string
  default     = "Standard"
  description = "The MicrosoftAD edition (Standard or Enterprise)"
}

variable "ec2_public_key" {
  type = string
}

variable "ec2_private_key_path" {
  type    = string
  default = "" #tfsec:ignore:general-secrets-sensitive-in-variable
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ec2_windows_server_version" {
  type    = string
  default = 2016
}

variable "ado_org_name" {
  type        = string
  description = "The name of the Azure DevOps organisation"
}

variable "ado_project_name" {
  type        = string
  description = "The name of the Azure DevOps project, to deploy the agent into"
}

variable "ado_deployment_group" {
  type        = string
  description = "The name of the Azure DevOps deployment group, in the project, to deploy the agent into"
}

variable "ado_access_token" {
  type        = string
  description = "An Azure Personal Access Token with 'Read & manage' permission to Deployment Groups"
}

variable "workload_dns_zone_name" {
  type = string
}
