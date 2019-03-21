 # Exit if any of the intermediate steps fail
set -eu

GRPCURL=$1
PASSWORD=$2
APPNAME=$3 # argocd-janitor
NAMESPACE=$4 # selfservice
PROJECT=$5 # selfservice
DESTSERVER=$6 # https://kubernetes.default.svc
REPOSITORY=$7 # git@github.com:dfds/infrastructure-manifests.git
OVERLAYPATH=$8 # selfservice/overlays/production

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
if [ -z "$APPNAME" ]
then
    echo "\$APPNAME is empty"
    exit 1
fi
# Exit if variable is empty
if [ -z "$NAMESPACE" ]
then
    echo "\$NAMESPACE is empty"
    exit 1
fi
# Exit if variable is empty
if [ -z "$PROJECT" ]
then
    echo "\$PROJECT is empty"
    exit 1
fi
# Exit if variable is empty
if [ -z "$DESTSERVER" ]
then
    echo "\$DESTSERVER is empty"
    exit 1
fi
# Exit if variable is empty
if [ -z "$REPOSITORY" ]
then
    echo "\$REPOSITORY is empty"
    exit 1
fi
# Exit if variable is empty
if [ -z "$OVERLAYPATH" ]
then
    echo "\$OVERLAYPATH is empty"
    exit 1
fi

# Setup Argo CD context with existing password. Uses GRPC
argocd login $GRPCURL --username admin --password "$PASSWORD"

# Default to 0 so that we dont create project
EXIT_CODE=0

# Get project. If exists, exit code is 0. Captures exit code.
argocd app get $APPNAME || EXIT_CODE=$? && true ; 
if [ $EXIT_CODE -ne 0 ]
then
    echo "Creating application $APPNAME"
    argocd app create $APPNAME --dest-namespace $NAMESPACE --dest-server $DESTSERVER --project $PROJECT --sync-policy automated --repo $REPOSITORY --path $OVERLAYPATH
else
    echo "Not creating application ($APPNAME) as it already exists."
fi
