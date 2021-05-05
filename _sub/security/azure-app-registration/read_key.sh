#!/bin/bash

# Exit if any of the intermediate steps fail
set -ex

# Prints commands if debug mode is enabled
# [ "$DEBUG" == 'true' ] && set -x

# Parse JSON arguments - for calling via Terraform data/program
# https://www.terraform.io/docs/providers/external/data_source.html
eval "$(jq -r '@sh "KEY_PATH_S3=\(.key_path_s3)"')"
eval "$(jq -r '@sh "REGION=\(.s3_region)"')"

# Read key file from S3
aws --region "$REGION" s3 cp $KEY_PATH_S3 -
