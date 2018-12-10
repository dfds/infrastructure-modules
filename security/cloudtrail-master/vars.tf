#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = "string"
}

variable "cloudtrail_central_s3_bucket" {
  type = "string"
}

