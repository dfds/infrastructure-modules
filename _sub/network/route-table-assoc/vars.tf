# variable "count_assoc" {
#   description = "The number of associations to make"
# }

variable "subnet_ids" {
  type = "list"
}

variable "route_table_id" {
  type = "string"
}
