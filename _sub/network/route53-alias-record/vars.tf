variable "deploy" {
  default = true
}

variable "zone_id" {}

variable "record_name" {
  type    = "list"
}
variable "record_type" {}

variable "alias_target_dns_name" {
  
}

variable "alias_target_zone_id" {
  
}