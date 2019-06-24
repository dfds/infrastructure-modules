# Terminate script if any errors occur
set -e


# Validate number of arguments
if [ "$#" -ne 3 ]; then
    echo "Expected 3 arguments: ACCOUNT_ID, DESTINATION_ID, AWS_ASSUME_ARN"
    exit 1
fi

# Define variables
ACCOUNT_ID=$1
DESTINATION_ID=$2
AWS_ASSUME_ARN=$3


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


# Assume specified AWS IAM role
AWS_ASSUMED_CREDS=($(aws sts assume-role \
    --role-arn "$AWS_ASSUME_ARN" \
    --role-session-name "MoveAccount" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text))
SplitAssumedCreds


# Get root parent ID
echo "Getting ID of AWS Organizations root"
ROOT_ID=$(AWS_ACCESS_KEY_ID=${AWS_ASSUMED_ACCESS_KEY_ID} \
    AWS_SECRET_ACCESS_KEY=${AWS_ASSUMED_SECRET_ACCESS_KEY} \
    AWS_SESSION_TOKEN=${AWS_ASSUMED_SESSION_TOKEN} \
    aws organizations list-roots | jq '.Roots | .[] | .Id' | tr -d '"')

if [[ -z $ROOT_ID ]]; then
    echo "Unable to determine AWS Organizations root ID, aborting"
    exit 1
fi


# Move account
if AWS_ACCESS_KEY_ID=${AWS_ASSUMED_ACCESS_KEY_ID} \
    AWS_SECRET_ACCESS_KEY=${AWS_ASSUMED_SECRET_ACCESS_KEY} \
    AWS_SESSION_TOKEN=${AWS_ASSUMED_SESSION_TOKEN} \
    aws organizations list-accounts-for-parent --parent-id $ROOT_ID | grep "\"Id\": \"$ACCOUNT_ID\"" > /dev/null

then

    echo "Account $ACCOUNT_ID found in root, moving to capability OU"
    AWS_ACCESS_KEY_ID=${AWS_ASSUMED_ACCESS_KEY_ID} \
        AWS_SECRET_ACCESS_KEY=${AWS_ASSUMED_SECRET_ACCESS_KEY} \
        AWS_SESSION_TOKEN=${AWS_ASSUMED_SESSION_TOKEN} \
        aws organizations move-account --account-id $ACCOUNT_ID --source-parent-id $ROOT_ID --destination-parent-id $DESTINATION_ID

else

    echo "Account $ACCOUNT_ID not found in root, skipping"

fi