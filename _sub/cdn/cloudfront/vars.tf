variable "cdn_origins" {
  
}

variable "cdn_comment" {
  
}

variable "acm_certificate_arn" {
  default = ""
}

variable "aliases" {
  default = []
  type = "list"
}