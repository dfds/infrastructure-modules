#!/bin/bash
set -eu -o pipefail

# Init
helm init --client-only
helm repo add servicecatalog "https://svc-catalog-charts.storage.googleapis.com"
helm repo add aws-sb "https://awsservicebroker.s3.amazonaws.com/charts"
az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID

# Show the plan of what will be applied
terragrunt plan-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false

# Apply the configuration
terragrunt apply-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve

# Sleep ?

# Apply the configuration again, to see if any issues occur when updating existing configuration
terragrunt apply-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve

# Add tests here

# Cleanup
terragrunt destroy-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
