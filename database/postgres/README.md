# Terraform aws rds postgres module
This module is designed to create a database based on an existing snapshot with the recommended settings like ssl.

The connection strings, passwords etc can be found in parameter store in the same account/region as the database.

## Input requirements (Values are only for examples)
* Required - These MUST be set
  * aws_region = "eu-west-1" (**Required** | **Destrutive** if changed)
  * application = "application" (**Required** | **Destrutive** if changed)
  * db_name = "papp" (**Required** | **Destrutive** if changed)
  * db_master_username = "test" (**Required** | **Destrutive** if changed)
  * db_master_password = "testtesttest" (**Required** | Can be used for changing password)
* Semi-Optional - These SHOULD be set
  * environment = "prod" (**Semi-Optional** | **Destrutive** if changed **!!!CAUTION!!!**)
  * db_deletion_protection = true (**Semi-Optional** | SHOULD be set to **true** for production)
  * skip_final_snapshot = false (**Semi-Optional** | SHOULD be set to **false** for production)
* Optional
  * db_storage_type = "gp2" (Optional | **Destrutive** if changed)
  * db_instance_class = "db.t2.micro" (Optional)
  * db_allocated_storage = 20 (Optional | Can only be increased)
  * db_engine_major_version = "10" (Optional | **Destrutive** if changed | Can only be increased)
  * db_engine_minor_version = "9" (Optional | Can only be increased)
  * db_port = 5432 (Optional)
