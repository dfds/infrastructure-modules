# Terraform aws rds postgres module
This module is designed to create a database based on an existing snapshot with the recommended settings like ssl.

The connection strings, passwords etc can be found in parameter store in the same account/region as the database.

## Input requirements (Values are only for examples)
* aws_region = "eu-central-1" (**Required** | **Destrutive** if changed)
* application = "application" (**Required** | **Destrutive** if changed)
* environment = "prod" (**Required** | **Destrutive** if changed)
* db_name = "papp" (**Required** | **Destrutive** if changed)
* db_master_username = "test" (**Required** | **Destrutive** if changed)
* db_master_password = "testtesttest" (**Required** | Can be used for changing password)
* db_deletion_protection = true (**Semi-Optional** | Should NOT be set to **false** for production)
* skip_final_snapshot = false (**Semi-Optional** | Should NOT be set to **true** for production)
* db_storage_type = "gp2" (Optional | **Destrutive** if changed)
* db_instance_class = "db.t2.micro" (Optional)
* db_allocated_storage = 20 (Optional | Can only be increased)
* db_engine_major_version = "10" (Optional | **Destrutive** if changed | Can only be increased)
* db_engine_minor_version = "9" (Optional | Can only be increased)
* db_port = 5432 (Optional)
