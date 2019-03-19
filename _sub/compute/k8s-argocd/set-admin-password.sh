# Exit if any of the intermediate steps fail
set -e

# Set arguments to better names
KUBECONFIG=$1
GRPCURL=$2
PASSWORD=$3

# Exit if variable is empty
if [ -z "$KUBECONFIG" ]
then
    echo "\$KUBECONFIG is empty"
    exit 1
fi
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

# Default Argo CD password is derived from pod-name
oldpassword=`kubectl --kubeconfig $KUBECONFIG get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2`

if [-z "$oldpassword"]
then
    echo "Unable to find existing default password for ArgoCD server"
    exit 1
fi

# Setup Argo CD context with existing password. Uses GRPC
argocd login $GRPCURL --username admin --password "$oldpassword"
# Change password to desired
argocd account update-password --current-password "$oldpassword" --new-password "$PASSWORD"