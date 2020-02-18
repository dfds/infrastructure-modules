variable "names" {
  type = set(string)
}

variable "scan_on_push" {
  type = bool
}

variable "pull_principals" {
  type = list(string)
}
