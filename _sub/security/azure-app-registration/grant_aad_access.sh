# Exit if any of the intermediate steps fail
set -e

# Define varibales
APPLICATION_ID=$1

WINDOWS_AZURE_AD_IDENT=00000002-0000-0000-c000-000000000000
SIGN_IN_AND_READ_USER_PROFILE=311a71cc-e848-46a1-bdf8-97ff7156d8e6


# Determine if the permission already exists
EXISTING_PERMISSION=$(az ad app permission list --id $APPLICATION_ID | jq --arg azureadident "$WINDOWS_AZURE_AD_IDENT" --arg signinprofile "$SIGN_IN_AND_READ_USER_PROFILE" '.[] | select(.resourceAppId==$azureadident) | .resourceAccess[] | select(.id==$signinprofile)')
#echo $EXISTING_PERMISSION
# Determine if app key already exist in App Reg

if [ -z "$EXISTING_PERMISSION" ]; then
    echo "Adding permission to Application in Azure AD"
    az ad app permission add --id $APPLICATION_ID --api $WINDOWS_AZURE_AD_IDENT --api-permissions ${SIGN_IN_AND_READ_USER_PROFILE}=Scope
    
    # Currently, it's not possible to evaluate the existence of an existing grant. We rely on a non-existent grant when adding permission.
    echo "Granting access to permission"
    az ad app permission grant --id $APPLICATION_ID --api $WINDOWS_AZURE_AD_IDENT --expires never
else
    echo "Permission already exists"
fi