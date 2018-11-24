#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "user_pool_name" {
  type = "string"
}

variable "dns_zone_name" {
  type = "string"
}