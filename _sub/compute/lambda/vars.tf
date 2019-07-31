variable "lambda_function_name" {
  
}

variable "lambda_role_name" {
  
}

variable "lambda_function_handler" {
  description = "The source file without file extension"
}

variable "lambda_env_variables" {
  type = "map"
}

variable "s3_bucket" {
  description = "The s3 bucket that contains the lambda function zip file"
}

variable "s3_key" {
  description = "File path for the lambda function zip inside the s3 bucket"
}

variable "runtime" {
  default = "nodejs10.x"
}

variable "aws_region" {
  
}
