variable "name" {
  type        = string
  description = "The fully qualified name for the directory, such as corp.example.com"
}

variable "password" {
  type        = string
  description = "The password for the directory administrator"
}

variable "edition" {
  type        = string
  default     = "Standard"
  description = "The MicrosoftAD edition (Standard or Enterprise)"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The identifiers of the subnets for the directory servers (2 subnets in 2 different AZs)"
}
