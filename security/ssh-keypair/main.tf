# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend "s3" {
  }
}

provider "aws" {
  region  = var.aws_region

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

resource "tls_private_key" "keypair" {
  count     = var.deploy ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "aws_ssm_parameter" "putPublicKey" {
  count       = var.deploy ? 1 : 0
  name        = "/eks/${var.keypairname}/rsa_public"
  description = "Public key of ${var.keypairname} ssh keypair"
  type        = "SecureString"
  value = element(
    concat(tls_private_key.keypair.*.public_key_openssh, [""]),
    0,
  )
  overwrite = "true"
}

resource "aws_ssm_parameter" "putPrivateKey" {
  count       = var.deploy ? 1 : 0
  name        = "/eks/${var.keypairname}/rsa_private"
  description = "Private key of ${var.keypairname} ssh keypair"
  type        = "SecureString"
  value       = element(concat(tls_private_key.keypair.*.private_key_pem, [""]), 0)
  overwrite   = "true"
}

