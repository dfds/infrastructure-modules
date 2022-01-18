# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

# --------------------------------------------------
# Postgres database
# --------------------------------------------------

module "postgres" {
  source                        = "../../_sub/database/postgres"
  application                   = var.application
  environment                   = var.environment
  db_name                       = var.db_name
  db_master_username            = var.db_master_username
  db_master_password            = var.db_master_password
  db_port                       = var.db_port
  skip_final_snapshot           = var.skip_final_snapshot
  engine_version                = var.engine_version
  db_instance_class             = var.db_instance_class
  db_allocated_storage          = var.db_allocated_storage
  allow_major_version_upgrade   = var.allow_major_version_upgrade
  ssl_mode                      = var.ssl_mode
}

module "param_store_pghost" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/${var.application}/postgres/${var.environment}/pghost"
  key_description = "PG host for postgres database ${var.application}-${var.environment}"
  key_value       = module.postgres.host
}

module "param_store_pguser" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/${var.application}/postgres/${var.environment}/pguser"
  key_description = "PG user for postgres database ${var.application}-${var.environment}"
  key_value       = var.db_master_username
}

module "param_store_pgpassword" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/${var.application}/postgres/${var.environment}/pgpassword"
  key_description = "PG password for postgres database ${var.application}-${var.environment}"
  key_value       = var.db_master_password
}

module "param_store_pgdatabase" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/${var.application}/postgres/${var.environment}/pgdatabase"
  key_description = "PG database for postgres database ${var.application}-${var.environment}"
  key_value       = var.db_name
}

module "param_store_pgport" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/${var.application}/postgres/${var.environment}/pgport"
  key_description = "PG port for postgres database ${var.application}-${var.environment}"
  key_value       = module.postgres.port
}

module "param_store_pgconnection_string" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/${var.application}/postgres/${var.environment}/pgconnection_string"
  key_description = "PG connection string for postgres database ${var.application}-${var.environment}"
  key_value       = module.postgres.connection_string
}

