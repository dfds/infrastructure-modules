variable "names" {
  type = set(string)
}

variable "scan_images" {
  type = bool
}

variable "pull_principals" {
  type = list(string)
}
