#!/bin/bash
set -eu -o pipefail

# Show the plan of what will be applied
terragrunt plan-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve

# Apply the configuration
terragrunt apply-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve

# Sleep ?

# Apply the configuration again, to see if any issues occur when updating existing configuration
terragrunt apply-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve

# Add tests here

# Cleanup
terragrunt destroy-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
