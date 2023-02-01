variable "deploy" {
  type    = bool
  default = true
}

variable "zone_id" {
  type = string
}

variable "record_name" {
  type = list(string)
}

variable "record_type" {
  type = string
}

variable "record_value" {
  type = string
}

variable "record_ttl" {
  type    = number
  default = 900
}
