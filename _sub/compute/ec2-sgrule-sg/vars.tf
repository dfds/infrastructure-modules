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

variable "source_security_group_id" {
  type        = string
  description = "The security group id to allow access to/from, depending on the type. Cannot be specified with cidr_blocks and self"
}

variable "from_port" {
  type = number
}

variable "to_port" {
  type = number
}
