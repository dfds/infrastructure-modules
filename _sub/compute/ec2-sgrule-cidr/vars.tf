variable "security_group_id" {
  type        = string
  description = "The security group to apply this rule to"
}

variable "description" {
  type = string
}

variable "type" {
  type        = string
  default     = "ingress"
  description = "The type of rule being created. Valid options are ingress (inbound) or egress (outbound)"
}

variable "protocol" {
  type        = string
  default     = "tcp"
  description = "The protocol. If not icmp, icmpv6, tcp, udp, or all use the protocol number"
}

variable "cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks. Cannot be specified with source_security_group_id"
}

variable "from_port" {
  type = number
}

variable "to_port" {
  type = number
}

variable "self" {
  type        = bool
  default     = false
  description = "If true, the security group itself will be added as a source to this ingress rule. Cannot be specified with source_security_group_id"
}
