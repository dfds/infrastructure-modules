variable "name" {
  type        = string
  description = "Namespace name"
}

variable "namespace_labels" {
  type    = map(any)
  default = {}
}
