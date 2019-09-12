variable "deploy" {
  default = true
}

variable "s3_bucket" {
  description = "Name of the s3 bucket to use."  
}

variable "key" {
  description = "Name of the filepath of object inside s3 bucket. An example could be v1.0.0/example.zip."
}

variable "filepath" {
  description = "Path for the object to upload to s3 bucket."
}