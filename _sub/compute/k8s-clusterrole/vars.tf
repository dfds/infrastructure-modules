variable "name" {
  type = string
}

variable "rules" {
  type = list(object({
    api_groups = list(string)
    resources  = list(string)
    verbs      = list(string)
  }))
}
