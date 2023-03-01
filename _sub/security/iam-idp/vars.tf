variable "provider_name" {
  type        = string
  description = "The fully-qualified domain name of the ADFS server, e.g. adfs.company.tld"
}

variable "adfs_fqdn" {
  type        = string
  description = "The fully-qualified domain name of the ADFS server, e.g. adfs.company.tld"
}

variable "assume_role_arns" {
  type        = list(string)
  description = "Optional: The trusted role ARNs to be included in the output assume role policy"
  default     = []
}

