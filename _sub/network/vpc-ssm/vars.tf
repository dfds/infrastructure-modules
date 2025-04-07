variable "vpc_id" {
  type = string
}

variable "subnets" {
    type = list(string)
    default = []
}

variable "tags" {
    type = map(string)
    default = {}
}