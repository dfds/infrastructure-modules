# Exit if any of the intermediate steps fail
set -e


# Parse JSON arguments - for calling via Terraform data/program 
# https://www.terraform.io/docs/providers/external/data_source.html
eval "$(jq -r '@sh "KEY_PATH_S3=\(.key_path_s3)"')"


# Read key file from S3
aws s3 cp $KEY_PATH_S3 -