provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

    version = "~> 1.40"
}

terraform {
    # The configuration for this backend will be filled in by Terragrunt
    backend "s3" {}
    required_version = "~> 0.11.7"
}

resource "aws_cognito_user_pool" "pool" {
  name = "${var.user_pool_name}"
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.user_pool_domain_name}"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
}

resource "aws_cognito_user_pool_client" "client" {
  name = "${var.user_pool_client_name}"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
  generate_secret     = true
}

resource "aws_iam_saml_provider" "testprovider" {
  name                   = "testprovider"
  saml_metadata_document = "${file("BlasterAzureAD.xml")}"
}

resource "aws_cognito_identity_provider" "adfs" {
  user_pool_id  = "${aws_cognito_user_pool.pool.id}"
  provider_name = "${var.user_pool_identity_provider_name}"
  provider_type = "SAML"
  idp_identifiers = ["{aws_iam_saml_provider.testprovider.arn}"]

  attribute_mapping {
    Email    = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    Name = "http://schemas.microsoft.com/identity/claims/displayname"
  }
}

