variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "gateway_id" {
  type = string
}

variable "nat_gateway_id" {
  type    = string
  default = null
}

variable "tags" {
  description = "The tags to apply to the resources"
  type        = map(string)
  default     = {}
}
