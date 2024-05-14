#variable "owners" {
#  type = list(string)
#  description = "List of owners of the group"
#}

variable "display_name" {
  type = string
  description = "The display name for the group"
}

variable "administrative_unit_ids" {
  type = list(string)
}
