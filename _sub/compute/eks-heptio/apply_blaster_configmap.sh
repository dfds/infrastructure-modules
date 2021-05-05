#!/bin/bash

# Exit if any of the intermediate steps fail
set -ex

# Prints commands if debug mode is enabled
# [ "$DEBUG" == 'true' ] && set -x


# Ensure at least two arguments were passed
if [ -z "$2" ]; then
    echo "Need at least two arguments"
    exit
fi


# Define varibales
APPLY_S3_CONFIGMAP=0
REGION=$1
KUBE_CONFIG_PATH=$2
CONFIGMAP_BUCKET=$3
CONFIGMAP_KEY=$4
CONFIGMAP_PATH_S3=s3://${CONFIGMAP_BUCKET}/${CONFIGMAP_KEY}
DEFAULT_CONFIGMAP_PATH=$5


# Use function to delay expansion of variable containing assumed creds
function SplitAssumedCreds()
{
    AWS_ASSUMED_ACCESS_KEY_ID=${AWS_ASSUMED_CREDS[0]}
    AWS_ASSUMED_SECRET_ACCESS_KEY=${AWS_ASSUMED_CREDS[1]}
    AWS_ASSUMED_SESSION_TOKEN=${AWS_ASSUMED_CREDS[2]}
    echo "Assumed access key ID:     $AWS_ASSUMED_ACCESS_KEY_ID"
    echo "Assumed secret access key: ${AWS_ASSUMED_SECRET_ACCESS_KEY:0:5}***${AWS_ASSUMED_SECRET_ACCESS_KEY: -5}"
    echo "Assumed session token:     $AWS_ASSUMED_SESSION_TOKEN"
}


# Generate AWS CLI config files, if 
if [ -n "$4" ]; then
    AWS_ASSUME_ARN=$6
    AWS_ASSUMED_CREDS=($(aws --region "$REGION" sts assume-role \
        --role-arn "$AWS_ASSUME_ARN" \
        --role-session-name "ApplyBlasterConfigmap" \
        --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
        --output text))
    SplitAssumedCreds
fi


# Determine if configmap file exists in S3
if [ -n "$AWS_ASSUMED_CREDS" ]; then
    AWS_ACCESS_KEY_ID=${AWS_ASSUMED_ACCESS_KEY_ID} \
    AWS_SECRET_ACCESS_KEY=${AWS_ASSUMED_SECRET_ACCESS_KEY} \
    AWS_SESSION_TOKEN=${AWS_ASSUMED_SESSION_TOKEN} \
    aws --region "$REGION" s3 ls "$CONFIGMAP_PATH_S3" >/dev/null && APPLY_S3_CONFIGMAP=1
else
    aws --region "$REGION" s3 ls "$CONFIGMAP_PATH_S3" >/dev/null && APPLY_S3_CONFIGMAP=1
fi


# Output current configmap
# echo "Current configmap:"
# kubectl --kubeconfig $KUBE_CONFIG_PATH -n kube-system get configmap aws-auth -o yaml


# Apply configmap
if [ $APPLY_S3_CONFIGMAP -eq 1 ]; then

    echo "Applying configmap from ${CONFIGMAP_PATH_S3}:"

    if [ -n "$AWS_ASSUMED_CREDS" ]; then
        AWS_ACCESS_KEY_ID=${AWS_ASSUMED_ACCESS_KEY_ID} \
        AWS_SECRET_ACCESS_KEY=${AWS_ASSUMED_SECRET_ACCESS_KEY} \
        AWS_SESSION_TOKEN=${AWS_ASSUMED_SESSION_TOKEN} \
        aws --region "$REGION" s3 cp "$CONFIGMAP_PATH_S3" "/tmp/${CONFIGMAP_KEY}"
    else
        aws --region "$REGION" s3 cp "$CONFIGMAP_PATH_S3" "/tmp/${CONFIGMAP_KEY}"
    fi

    # cat /tmp/${CONFIGMAP_KEY}
    kubectl --kubeconfig "$KUBE_CONFIG_PATH" apply -f "/tmp/${CONFIGMAP_KEY}"

else

    echo "No configmap found at \"$CONFIGMAP_PATH_S3\" or permission denied. Applying default configmap."
    kubectl --kubeconfig "$KUBE_CONFIG_PATH" apply -f "$DEFAULT_CONFIGMAP_PATH"

fi