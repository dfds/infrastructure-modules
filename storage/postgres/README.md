# Terraform aws rds postgres module
This module is designed to create a database based on an exisiting snapshot with the recommended settings like ssl.

The connection strings, passwords etc can be found in parameter store in the same account/region as the database.

## Input rewuirements (Values are only for examples)
db_name = "papp" (Destructive if changed)
aws_region = "eu-central-1" (Destructive if changed)
db_snapshot = "application-postgres-final-prod" (After initial setup this input is ignored)
application = "application" (Destrutive if changed)
db_master_username = "test" (Destrutive if changed)
db_master_password = "testtesttest" (Cna be used for changing password)
skip_final_snapshot = false (Optional and should NOT be set to true for production)