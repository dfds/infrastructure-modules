# Even for global resources, you still need an AWS region for Terraform to talk to. This variable is automatically
# pulled in using the extra_arguments setting in the root terraform.tfvars file's Terragrunt configuration.
aws_region = "eu-west-1"