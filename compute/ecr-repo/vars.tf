variable "aws_region" {
  type = string
}

variable "names" {
  type = set(string)
}

variable "pull_principals" {
  type        = list(string)
  description = "A list of AWS IAM principals that should be allowed to pull images from this repo"
  default     = []
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}
