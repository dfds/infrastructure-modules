variable "deploy" {
  type    = bool
  default = true
}

variable "zone_id" {
}

variable "record_name" {
  type = list(string)
}

variable "record_type" {
}

variable "record_value" {
}

variable "record_ttl" {
  default = 900
}
