#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "deploy" {
  default = true
}
variable "dns_zone_name" {
  type = "string"
}

