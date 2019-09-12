variable "deploy" {
  default = true
}


variable "lambda_function_name" {
  
}

variable "lambda_role_name" {
  description = "Name of iam role to create for the lambda function."
}

variable "lambda_function_handler" {
  description = "The source file without file extension."
}

variable "lambda_env_variables" {
  type = "map"

  default = {}
}

variable "s3_bucket" {
  description = "The s3 bucket that contains the lambda function zip file."
}

variable "s3_key" {
  description = "File path for the lambda function zip inside the s3 bucket. An example could be v1.0.0/example.zip."
}

variable "runtime" {
  default = "nodejs10.x"
}

variable "publish" {
  default = true
  description = "Enable publishing under a new version. This is required when enabling in order to enable lambda function to be used by cloudfront."
}

