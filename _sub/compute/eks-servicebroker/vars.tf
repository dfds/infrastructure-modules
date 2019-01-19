#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "table_name" {}

variable "aws_region" {}

variable "workload_account_id" {}

variable "kiam_server_role_id" {}

variable "cluster_name" {}