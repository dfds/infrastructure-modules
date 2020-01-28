#!/bin/bash
set -eu -o pipefail

ACTION=$1

# Init
helm init --client-only
helm repo add servicecatalog "https://svc-catalog-charts.storage.googleapis.com"
helm repo add aws-sb "https://awsservicebroker.s3.amazonaws.com/charts"
az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID


if [ "$ACTION" = "plan" ]; then
    # Show the plan of what will be applied
    terragrunt plan-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false
fi


if [ "$ACTION" = "apply" ]; then
    # Apply the configuration
    terragrunt apply-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi


if [ "$ACTION" = "test" ]; then
    # Add tests here
fi


if [ "$ACTION" = "destroy" ]; then
    # Cleanup
    terragrunt destroy-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi
