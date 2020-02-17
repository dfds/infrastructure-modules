variable "aws_region" {
  type = string
}

variable "list_of_repos" {
  type = set(string)
}

variable "accounts" {
  type = list(string)
  description = "A list of AWS IAM principals that should be allowed to pull images from this repo"
  default = [
    "arn:aws:iam::738063116313:root", #dfds-oxygen
  ]
}

variable "scan_images" {
  type bool
  default = true
}