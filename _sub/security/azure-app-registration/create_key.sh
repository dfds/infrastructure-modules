#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Prints commands if debug mode is enabled
[ "$DEBUG" == 'true' ] && set -x


# Define varibales
CREATE_KEY=0
REGION=$1
APPLICATION_ID=$2
KEY_PATH_S3=$3


# Determine if app key already exist in App Reg
NUM_KEYS_AZ=$(az ad sp credential list --id $APPLICATION_ID | jq length) || NUM_KEYS_AZ=0
# NUM_KEYS_AZ=1 # debug
if [ $NUM_KEYS_AZ -eq 0 ]; then
    CREATE_KEY=1
fi


#az ad app permission add --id $APPLICATION_ID --api 00000002-0000-0000-c000-000000000000 --api-permissions 311a71cc-e848-46a1-bdf8-97ff7156d8e6=Scope
#az ad app permission grant --id $APPLICATION_ID --api 00000002-0000-0000-c000-000000000000


# Determine if key file exists in S3
aws --region "$REGION" s3 ls $KEY_PATH_S3 >/dev/null || CREATE_KEY=1


# Create new key
if [ $CREATE_KEY -eq 1 ]; then

    echo "No key found for app in Azure AD or key file not found in S3. Generating new."

#     OUTPUT="\
# {
#     \"appId\": \"$APPLICATION_ID\",
#     \"password\": \"$(date)\",
# }"
    
    az ad sp credential reset -n $APPLICATION_ID --years 100 | aws --region "$REGION" s3 cp - $KEY_PATH_S3 --content-type "application/json"

    # echo $OUTPUT | aws --region "$REGION" s3 cp - $KEY_PATH_S3 --content-type "application/json"

else

    echo "Not generating key."

fi