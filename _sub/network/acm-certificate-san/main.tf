# --------------------------------------------------
# Workarounds to https://github.com/hashicorp/terraform/issues/21416
# --------------------------------------------------

provider "aws" {
  region  = var.aws_region
  version = "~> 2.43"

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.43"
  alias   = "core"
}


# --------------------------------------------------
# Request certificate
# --------------------------------------------------

# Create the certificate request
resource "aws_acm_certificate" "cert" {
  count                     = var.deploy ? 1 : 0
  domain_name               = var.domain_name
  subject_alternative_names = var.core_alias
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
    # ignore_changes        = [subject_alternative_names] # workaround to https://github.com/terraform-providers/terraform-provider-aws/issues/8531
  }
}


# --------------------------------------------------
# Validate certificate
# --------------------------------------------------

locals {
  # Flatten the list of domain validation options, as it's enclosed in another list due to "count"
  flat_validation_options  = flatten(aws_acm_certificate.cert.*.domain_validation_options)
  
  # Find the index number of the domain name (not alias/SAN). This *might* always be zero, but there has been issues in the past: https://github.com/terraform-providers/terraform-provider-aws/issues/8531. Looking up to be sure.
  workload_index    = index(local.flat_validation_options[*].domain_name, var.domain_name)
  
  # Get the domain validation options for the workload DNS zone
  validate_workload = [local.flat_validation_options[local.workload_index]]

  # Get the domain validation options for the core ("alias") DNS zone - i.e. all other elements than local.workload_index
  validate_core     = [for i in range(0, length(local.flat_validation_options)) : local.flat_validation_options[i] if i != local.workload_index]
}

# Create validation DNS record in the workload DNS zone
resource "aws_route53_record" "workload" {
  count           = var.deploy ? 1 : 0
  name            = local.validate_workload[0]["resource_record_name"]
  type            = local.validate_workload[0]["resource_record_type"]
  zone_id         = local.dns_zone_id
  records         = [local.validate_workload[0]["resource_record_value"]]
  ttl             = 60
  allow_overwrite = true
}

# Create validation DNS record(s) in the core DNS zone (alternative names specified)
resource "aws_route53_record" "core" {
  count           = var.deploy ? length(var.core_alias) : 0
  name            = local.validate_core[count.index]["resource_record_name"]
  type            = local.validate_core[count.index]["resource_record_type"]
  zone_id         = local.core_dns_zone_id
  records         = [local.validate_core[count.index]["resource_record_value"]]
  ttl             = 60
  allow_overwrite = true

  provider = aws.core
}

# Validate the certificate using the DNS validation records created
resource "aws_acm_certificate_validation" "cert" {
  count           = var.deploy ? 1 : 0
  certificate_arn = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = concat(
    aws_route53_record.workload.*.fqdn,
    aws_route53_record.core.*.fqdn,
  )
}
