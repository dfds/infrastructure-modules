# Exit if any of the intermediate steps fail
set -e

# Set arguments to better names
KUBECONFIG=$1
HOSTURL=$2
GRPCURL=$3
PASSWORD=$4

# Exit if variable is empty
if [ -z "$KUBECONFIG" ]
then
    echo "\$KUBECONFIG is empty"
    exit 1
fi
# Exit if variable is empty
if [ -z "$HOSTURL" ]
then
    echo "\$HOSTURL is empty"
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

# # Download CLI matching the deployed version of Argo CD. Always bundled with platform.
# curl -o argocd https://$HOSTURL/download/argocd-linux-amd64
# # Make sure CLI is executable
# chmod +x argocd

# Default Argo CD password is derived from pod-name
oldpassword=`kubectl --kubeconfig $KUBECONFIG get pods -n argocd -l app=argocd-server -o name | cut -d'/' -f 2`

# Setup Argo CD context with existing password. Uses GRPC
argocd login $GRPCURL --username admin --password "$oldpassword"
# Change password to desired
argocd account update-password --current-password "$oldpassword" --new-password "$PASSWORD"