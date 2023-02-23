variable "deploy" {
  type    = bool
  default = true
}

variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(object({
    subnet_cidr               = string,
    prefix_reservations_cidrs = list(string),
  }))
  default = []
}

variable "cluster_name" {
  type = string
}

