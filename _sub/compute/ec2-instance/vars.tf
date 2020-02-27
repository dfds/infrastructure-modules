variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type = string
}

variable "private_key_path" {
  type    = string
  default = ""
}

variable "name" {
  type = string
}

variable "ami_platform_filters" {
  type = list(string)
}

variable "ami_name_filters" {
  type = list(string)
}

variable "ami_owners" {
  type = list(string)
}

variable "user_data" {
  type    = string
  default = ""
}

variable "vpc_security_group_ids" {
  type        = list(string)
  default     = []
  description = "A list of security group IDs to associate with"
}

variable "subnet_id" {
  type = string
}

variable "associate_public_ip_address" {
  default = false
}

variable "get_password_data" {
  default = false
}

variable "aws_managed_policy" {
  type        = string
  description = "The name of the AWS managed IAM policy to attach to the instance IAM role"
  default     = ""
}

