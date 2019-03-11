# Exit if any of the intermediate steps fail
set -eu

GRPCURL=$1
PASSWORD=$2
PROJECTNAME=$3

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
if [ -z "$PROJECTNAME" ]
then
    echo "\$PROJECTNAME is empty"
    exit 1
fi

# Setup Argo CD context with existing password. Uses GRPC
argocd login $GRPCURL --username admin --password "$PASSWORD"

# Default to 0 so that we dont create project
EXIT_CODE=0

# Get project. If exists, exit code is 0. Captures exit code.
argocd proj get $PROJECTNAME || EXIT_CODE=$? && true ; 
if [ $EXIT_CODE -ne 0 ]
then
    echo "Creating project $PROJECTNAME"
    # Limit access to namespace with same name and allow all sources
    argocd proj create $PROJECTNAME -d "https://kubernetes.default.svc,$PROJECTNAME" -s "*"
else
    echo "Not creating project ($PROJECTNAME) as it already exists."
fi
