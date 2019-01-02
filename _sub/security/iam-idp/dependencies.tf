data "http" "federation_metadata" {
    url = "https://${var.adfs_fqdn}/FederationMetadata/2007-06/FederationMetadata.xml"
}