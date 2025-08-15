variable "name" {
  description = "The name of the lambda function"
  type        = string
}

variable "path_to_index_file" {
  description = "The path to the index file."
  type        = string
  default     = "index.js"
}

variable "filename_out" {
  description = "The name of the output zip file"
  type        = string
  default     = "lambda.zip"
}

variable "templatefile_vars" {
  description = "The variables to pass to the template file"
  type        = map(string)
  default     = {}
}

variable "function_handler" {
  description = "The name of the lambda function handler"
  type        = string
  default     = "index.handler"
}

variable "function_runtime" {
  description = "The runtime of the lambda function"
  type        = string
  default     = "nodejs22.x"
}

variable "function_environment_variables" {
  description = "The environment variables for the lambda function"
  type        = map(string)
  default     = {}
}
