variable "deploy" {
  default = true
}

variable "domain_name" {
  description = "The common name of the certificate - the full/'true' name of the resource. E.g. 'service.workload1.company.tld'"
}

variable "dns_zone_name" {
  description = "The name of the DNS zone in which the common name resides. E.g. 'workload1.company.tld'"
}

variable "core_alt_names" {
  description = "A list of aliases/alternative names in the *parent* domain, the certficate should also be valid for. E.g. 'prettyurl.company.tld'"
  type = "list"
  default = []
}