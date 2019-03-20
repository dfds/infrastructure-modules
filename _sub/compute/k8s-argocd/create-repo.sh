# Exit if any of the intermediate steps fail
set -eu

GRPCURL=$1
PASSWORD=$2
REPOSITORY=$3
PRIVATEKEYPATH=$4


# Exit if variable is empty
if [ -z "$GRPCURL" ]
then
    echo "\$GRPCURL is empty"
    exit 1
fi
# Exit if variable is empty
if [ -z "$PASSWORD" ]
then
    echo "\$PASSWORD is empty"
    exit 1
fi
# Exit if variable is empty
if [ -z "$REPOSITORY" ]
then
    echo "\$REPOSITORY is empty"
    exit 1
fi
# Exit if variable is empty
if [ -z "$PRIVATEKEYPATH" ]
then
    echo "\$PRIVATEKEYPATH is empty"
    exit 1
fi

# Setup Argo CD context with existing password. Uses GRPC
argocd login $GRPCURL --username admin --password "$PASSWORD"

# Default to 0 so that we dont create project
EXIT_CODE=0

# Get project. If exists, exit code is 0. Captures exit code.
argocd repo list | grep $REPOSITORY || EXIT_CODE=$? && true ; 
if [ $EXIT_CODE -ne 0 ]
then
    echo "Creating repository $REPOSITORY"
    # Limit access to namespace with same name and allow all sources
    argocd repo add $REPOSITORY --ssh-private-key-path $PRIVATEKEYPATH
else
    echo "Not creating repository ($REPOSITORY) as it already exists."
fi
