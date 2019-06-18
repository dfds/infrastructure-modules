# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend          "s3"             {}
  required_version = "~> 0.11.7"
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 2.0"

#   assume_role {
#     role_arn = "${var.aws_assume_role_arn}"
#   }
}


# --------------------------------------------------
# Postgres database
# --------------------------------------------------

module "postgres_restore" {
  source       = "../../_sub/storage/postgres-restore"
  db_snapshot = "${var.db_snapshot}"
  application = "${var.application}"
  db_name = "${var.db_name}"
  db_master_username = "${var.db_master_username}"
  db_master_password = "${var.db_master_password}"
}

module "param_store_pghost" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/postgres/${var.environment}/${var.application}/pghost"
  key_description = "PG host for postgres database ${var.environment}/${var.application}"
  key_value       = "${module.postgres_restore.pghost}"
}

module "param_store_pguser" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/postgres/${var.environment}/${var.application}/pguser"
  key_description = "PG user for postgres database ${var.environment}/${var.application}"
  key_value       = "${var.db_master_username}"
}

module "param_store_pgpassword" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/postgres/${var.environment}/${var.application}/pgpassword"
  key_description = "PG password for postgres database ${var.environment}/${var.application}"
  key_value       = "${var.db_master_password}"
}

module "param_store_pgdatabase" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/postgres/${var.environment}/${var.application}/pgdatabase"
  key_description = "PG database for postgres database ${var.environment}/${var.application}"
  key_value       = "${var.db_name}"
}

module "param_store_pgport" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/postgres/${var.environment}/${var.application}/pgport"
  key_description = "PG port for postgres database ${var.environment}/${var.application}"
  key_value       = "${var.db_port}"
}

module "param_store_pgconnection_string" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/postgres/${var.environment}/${var.application}/pgconnection_string"
  key_description = "PG connection string for postgres database ${var.environment}/${var.application}"
  key_value       = "${module.postgres_restore.pgconnection_string}"
}
