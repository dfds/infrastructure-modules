# Exit if any of the intermediate steps fail
set -e


# Define varibales
APPLY_CONFIGMAP=0
KUBE_CONFIG_PATH=$1
CONFIGMAP_PATH_S3=$2


# Determine if key file exists in S3
aws s3 ls $CONFIGMAP_PATH_S3 >/dev/null && APPLY_CONFIGMAP=1


# Create new key
if [ $APPLY_CONFIGMAP -eq 1 ]; then
    echo "Applying configmap from $CONFIGMAP_PATH_S3"
    aws s3 cp $CONFIGMAP_PATH_S3 - | kubectl -f -
else
    echo "No configmap found at $CONFIGMAP_PATH_S3"
fi