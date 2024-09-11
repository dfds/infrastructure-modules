variable "aws_region" {
  type        = string
  description = "The AWS region to deploy the IPAM in."
}

variable "aws_assume_role_arn" {
  type        = string
  description = "The ARN of the role to assume to deploy the IPAM. This is normally the ARN of the network account in AWS Organizations."
}

variable "ipam_name" {
  type        = string
  description = "The name of the IPAM instance."
}

variable "ipam_regions" {
  type        = list(string)
  description = "The regions to support for IPAM."
  default     = ["eu-west-1", "eu-central-1"]
}

variable "ipam_scope_name" {
  type        = string
  description = "The name of the additional private scope"
  default     = "private"
}

variable "ipam_cascade" {
  type        = bool
  description = "Whether to cascade the deletion of the IPAM"
  default     = true
}

variable "ipam_pools_cascade" {
  type        = bool
  description = "Whether to cascade the deletion of the IPAM pools."
  default     = true
}

variable "ipam_pools" {
  type = map(object({
    cidr           = string
    address_family = optional(string, "ipv4")
    locale         = optional(string, null)
    sub_pools = optional(map(object({
      cidr = string
    })), {})
  }))
  description = <<EOF
    The pools to create in the IPAM.
    The key of an optional sub pool must be a region name that is in the ipam_regions list.

    Example:
    ipam_pools = {
      "main" = {
        cidr = "192.168.0.0/13"
      }
      "platform" = {
        cidr = "192.168.0.0/15"
        sub_pools = {
          "us-east-1" = {
            cidr = "192.168.0.0/17"
          }
          "us-east-2" = {
            cidr = "192.168.128.0/17"
          }
        }
      }
    }
EOF
}

variable "ipam_prefix" {
  type        = string
  description = "Optional prefix to use for the IPAM scope and pools."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}
