# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "dfds-qa-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
  }
}

retryable_errors = [
  ".*timeout.*",
  ".*connection timed out.*",
  ".*connection reset.*"
]

# Configure Terragrunt to use common var files to help you keep often-repeated variables (e.g., account ID) DRY.
# Note that even though Terraform automatically pulls in terraform.tfvars, we include it explicitly at the end of the
# list to make sure its variables override anything in the common var files.
terraform {
  extra_arguments "common_vars" {
    commands = "${get_terraform_commands_that_need_vars()}"

    optional_var_files = [
      "${find_in_parent_folders("account.tfvars", "skip-account-if-does-not-exist")}",
      "${find_in_parent_folders("region.tfvars", "skip-region-if-does-not-exist")}",
      "${find_in_parent_folders("env.tfvars", "skip-env-if-does-not-exist")}",
      "terraform.tfvars"
    ]
  }
}
