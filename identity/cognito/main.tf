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

resource "aws_cognito_identity_provider" "adfs" {
  user_pool_id  = "${aws_cognito_user_pool.pool.id}"
  provider_name = "${var.user_pool_identity_provider_name}"
  provider_type = "SAML"
  provider_details = {
      // https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_CreateIdentityProvider.html#CognitoUserPools-CreateIdentityProvider-request-AttributeMapping
      MetadataURL = "https://login.microsoftonline.com/${var.azure_ad_tenant_id}/FederationMetadata/2007-06/FederationMetadata.xml"
      
  }
  attribute_mapping {
    Email    = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    Name = "http://schemas.microsoft.com/identity/claims/displayname"
  }
}


resource "aws_cognito_user_pool_client" "client" {
  name = "${var.user_pool_client_name}"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
  generate_secret     = true
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["phone", "email","openid","profile","aws.cognito.signin.user.admin"]
  supported_identity_providers = ["${var.user_pool_identity_provider_name}"]
  callback_urls = ["${var.build_callback_url}"],
  logout_urls = ["${var.build_logout_url}"]

  depends_on = ["aws_cognito_identity_provider.adfs"]

}
resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.identity_pool_name}"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = "${aws_cognito_user_pool_client.client.id}"
    provider_name           = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.pool.id}"
    server_side_token_check = false
  }
}

// TODO : https://www.terraform.io/docs/providers/aws/r/cognito_identity_pool_roles_attachment.html

