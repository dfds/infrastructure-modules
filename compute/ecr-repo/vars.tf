variable "aws_region" {
  type = string
}

variable "names" {
  type = set(string)
}

variable "pull_principals" {
  type = list(string)
  description = "A list of AWS IAM principals that should be allowed to pull images from this repo"
  default = []
}

variable "scan_images" {
  type = bool
  default = true
}
