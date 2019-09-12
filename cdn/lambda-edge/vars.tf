# --------------------------------------------------
# Terraform
# --------------------------------------------------

variable "aws_region" {
  type = "string"
}

variable "aws_assume_role_arn" {
  type = "string"
}



variable "deploy_lambda_edge_func" {
  default = true
}

variable "lambda_function_handler" {
  description = "Name of the file the contains lambda code without file extension. Example 'redirect-rules'"
}

variable "s3_bucket" {
  description = "The s3 bucket that contains the lambda function zip file."
}


variable "lambda_edge_zip_filepath" { 
  description = "The path of the zip file that contains lambda source code to uploade."
}


variable "lambda_edge_prefix" {
  default = ""
  description = "A proper prefix for lambda@edge function."
}