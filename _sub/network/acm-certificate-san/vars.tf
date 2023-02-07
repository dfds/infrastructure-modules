variable "deploy" {
  type    = bool
  default = true
}

variable "domain_name" {
  type        = string
  description = "The common name of the certificate - the full/'true' name of the resource. E.g. 'service.workload1.company.tld'"
}

variable "dns_zone_name" {
  type        = string
  description = "The name of the DNS zone in which the common name resides. E.g. 'workload1.company.tld'"
}

variable "core_alias" {
  description = "A list of aliases/alternative names in the *parent* domain, the certficate should also be valid for. E.g. 'prettyurl.company.tld'"
  type        = list(string)
  default     = []
}


# --------------------------------------------------
# Workarounds to https://github.com/hashicorp/terraform/issues/21416
# --------------------------------------------------

variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}
