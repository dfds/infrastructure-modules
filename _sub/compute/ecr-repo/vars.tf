variable "name" {
  type = string
}

variable "scan_images" {
  type = bool
}

variable "pull_principals" {
  type = list(string)
}
