#!/bin/bash
set -eu -o pipefail

echo terragrunt plan-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
echo terragrunt apply-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
# Add tests here
echo terragrunt destroy-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
