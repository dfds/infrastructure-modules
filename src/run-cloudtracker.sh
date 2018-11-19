#!/bin/sh

# Verify arg 1 was passed
if [ "$1" = "" ]; then
  echo "Error. 1 argument expected: Target Account name"
  exit 1
fi

# Verify arg 2 was passed
if [ "$2" = "" ]; then
  echo "Error. 2 argument expected: Target AWS IAM user"
  exit 1
fi

# Verify arg 3 was passed
if [ "$3" = "" ]; then
  echo "Error. 3 argument expected: Audit bucket"
  exit 1
fi

aws_account_name=$1
aws_user=$2
aws_audit_bucket=$3

aws_account_id=$(aws sts get-caller-identity | jq '.["Account"]' -r)  && \

echo "athena:
  s3_bucket: ${aws_audit_bucket}
  path: ${aws_account_name}
accounts:
  - name: ${aws_account_name}
    id: ${aws_account_id}
    iam: account-data/account_iam_data.json" >> config.yaml


echo "Exporting account iam data..."
mkdir account-data  && \
aws iam get-account-authorization-details > account-data/account_iam_data.json && \
echo "Done."

echo "Running Cloudtracker..."
cloudtracker --account ${aws_account_name} --user ${aws_user} && \
echo "Done."