variable "subnet_id" {
  description = "The subnet ID of the public subnet in which the NAT Gateway will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the NAT Gateway."
  type        = map(string)
}
