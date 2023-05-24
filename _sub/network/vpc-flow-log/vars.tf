variable "log_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "retention_in_days" {
  type    = number
  default = 7
}
