variable "deploy" {
  default = true
}

# variable "dns_zone_name" {}

variable "domain_name" {}


variable "subject_alternative_names" {
  type = "list"
  default = []  
}

variable "dns_zone_id" {
  
}
