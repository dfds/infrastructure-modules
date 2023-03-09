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
    availability_zone         = string,
    prefix_reservations_cidrs = optional(list(string), []),
  }))
  default = []
}

variable "cluster_name" {
  type = string
}

