variable "aws_region" {
  type = "string"
}

variable "name" {
  description = "The name of the ECR repo to create"
  type        = "string"
}

variable "pull_principals" {
  description: "A list of AWS IAM principals that should be allowed to pull images from this repo"
  type    = "list"
  default = []
}
