variable "deploy" {
  default = true
}

variable "name" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "subnets" {
  type    = "list"
  default = []
}

variable "cluster_name" {
  type = "string"
}
