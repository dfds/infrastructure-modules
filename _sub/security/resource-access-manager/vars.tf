variable "resource_share_name" {
  type        = string
  description = "The name of the RAM resource share"
}

variable "resource_arns" {
  type        = list(string)
  description = "The ARNs of the resource to share"
  default     = []
}

variable "principals" {
  type        = list(string)
  description = "The ARNs of the principals to associate with the resource share"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}
