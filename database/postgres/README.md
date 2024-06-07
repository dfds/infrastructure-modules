# Terraform aws rds postgres module

This module is designed to create a database based on an existing snapshot with the recommended settings like ssl.

The connection strings, passwords etc can be found in parameter store in the same account/region as the database.

## Input requirements (Values are only for examples)

- db_name = "papp" (Destructive if changed)
- aws_region = "eu-central-1" (Destructive if changed)
- application = "application" (Destrutive if changed)
- db_master_username = "test" (Destrutive if changed)
- db_master_password = "<REDACTED>" (Can be used for changing password)
- skip_final_snapshot = false (Optional and should NOT be set to true for production)
- engine_version = 14 (Must be major version. Cannot be downgraded. Optional, but defaults to 14)
- db_instance_class = "db.t3.nano" RDS (database instance class. Optional, but defaults to "db.t3.micro")
- db_allocated_storage = 10 (The amount of space, in GB, to allocate for the database. Optional, but defaults to 20)
- db_max_allocated_storage = 30 (The space limit, in GB, which autoscaling can scale up to. Optional, default to 0 - autoscaling disabled)
- allow_major_version_upgrade = true (Define if major version upgrades to the Postgres engine are allowed. Optional, but defaults to true)
- db_backup_retention_period = 30 (The number of days to retain backups for. Optional, but defaults to 10)
- ca_cert_identifier = "rds-ca-rsa2048-g1" (The identifier of the CA certificate to use for the RDS instance)
- apply_immediately = true  (Specifies whether any database modifications are applied immediately, or during the next maintenance window)
