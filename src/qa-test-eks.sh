#!/bin/bash
set -eux #-o pipefail

BASEPATH=./test/integration
ACTION=$1
# $AWS_DEFAULT_REGION

function cleanup_roles {

    ROLEPREFIX=$1

    # Get roles
    IFS=$'\n' roles=($(aws --no-cli-pager --region "$REGION" iam list-roles --output json | jq -r --arg ROLEPREFIX "$ROLEPREFIX" '.Roles[] | select( .RoleName | contains($ROLEPREFIX) ) | .RoleName'))

    # Detach any policies and delete roles
    for role in "${roles[@]}"; do
        # Detach policies
        aws --region "$REGION" iam list-attached-role-policies --role-name "$role" --output json | jq '.AttachedPolicies[].PolicyArn' | xargs -tr -L1 aws --no-cli-pager --region "$REGION" iam detach-role-policy --role-name "$role" --policy-arn || true

        # Remove the role from an instance profile (if any)
        IAM_PROFILE=$(aws --region "$REGION" iam list-instance-profiles-for-role --role-name "$role" --output json | jq -r '.InstanceProfiles[].InstanceProfileName')
        [[ ! -z "$IAM_PROFILE" ]] && aws --region "$REGION" iam remove-role-from-instance-profile --instance-profile-name "$IAM_PROFILE" --role-name "$role" || true

        # Delete role
        aws --region "$REGION" --no-cli-pager iam delete-role --role-name "$role" || true

        # Delete the instance profile
        [[ ! -z "$IAM_PROFILE" ]] && aws --region "$REGION" iam delete-instance-profile --instance-profile-name "$IAM_PROFILE"
    done

}


function cleanup_eni {
    # Get all Network interfaces and treat it as an array instead of a space separated string
    IFS=$'\n' nics=($(aws --no-cli-pager --region "$REGION" ec2 describe-network-interfaces --filters "Name=group-name,Values=eks-${CLUSTERNAME}-node" --query "NetworkInterfaces[].NetworkInterfaceId" --output json | jq -r '.[]'))

    # Loop over network interfaces and delete them one by one
    for nic in "${nics[@]}"; do
        aws --no-cli-pager --region "$REGION" ec2 delete-network-interface --network-interface-id $nic || true
    done

}


if [ "$ACTION" = "cleanup-cluster" ]; then
    REGION=$2
    CLUSTERNAME=$3

    # Remove specific resources that sometimes get left behind (always return true, as resource may have been successfully been cleaned up)
    cleanup_roles "eks-${CLUSTERNAME}-"
    cleanup_roles "${CLUSTERNAME}-"
    cleanup_eni
fi


if [ "$ACTION" = "cleanup-shared" ]; then
    REGION=$2

    # Remove specific resources that sometimes get left behind (always return true, as resource may have been successfully been cleaned up)
    cleanup_roles "Velero"
fi


if [ "$ACTION" = "apply-shared" ]; then
    SUBPATH=$2
    WORKDIR="${BASEPATH}/${SUBPATH}"

    # Apply the configuration
    terragrunt run-all apply --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi


if [ "$ACTION" = "apply-cluster" ]; then
    REGION=$2
    CLUSTERNAME=$3
    WORKDIR="${BASEPATH}/${REGION}/k8s-${CLUSTERNAME}"

    # Apply the configuration
    terragrunt run-all apply --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi


if [ "$ACTION" = "test" ]; then
    # --------------------------------------------------
    # Get kubeconfig path
    # --------------------------------------------------

    REGION=$2
    CLUSTERNAME=$3
    WORKDIR="${BASEPATH}/${REGION}/k8s-${CLUSTERNAME}/cluster"
    export KUBECONFIG=$(terragrunt output --raw kubeconfig_path --terragrunt-working-dir "$WORKDIR")

    # Debugging
    (cd "${BASEPATH}/suite" && exec pwd || true)
    (cd "${BASEPATH}/suite" && exec go version || true)
    (cd "${BASEPATH}/suite" && exec go env || true)

    # Run test suite
    (cd "${BASEPATH}/suite" && exec go test -v)
fi


if [ "$ACTION" = "destroy-cluster" ]; then
    RETURN=0
    REGION=$2
    CLUSTERNAME=$3
    WORKDIR="${BASEPATH}/${REGION}/k8s-${CLUSTERNAME}"

    # Disable cluster logging
    echo Disabling cluster logging
    aws --region "$REGION" eks update-cluster-config --name "$CLUSTERNAME" --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":false}]}' || true
    sleep 60

    # Essential cleanup commands (set RETURN=1 if fails)
    terragrunt destroy-all --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve || RETURN=1

    # Remove specific resources that sometimes get left behind (always return true, as resource may have been successfully been cleaned up)
    cleanup_roles "eks-${CLUSTERNAME}-"
    cleanup_eni

    # Return false, if any *eseential* commands failed
    if [ $RETURN -ne 0 ]; then
        false
    fi
fi


if [ "$ACTION" = "destroy-public-bucket" ]; then
    RETURN=0
    REGION=$2
    SUBPATH=$3
    WORKDIR="${BASEPATH}/${SUBPATH}"

    # Cleanup
    terragrunt run-all destroy --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve || RETURN=1

    # Return false, if any *eseential* commands failed
    if [ $RETURN -ne 0 ]; then
        false
    fi
fi

if [ "$ACTION" = "destroy-velero-bucket" ]; then
    RETURN=0
    REGION=$2
    SUBPATH=$3
    WORKDIR="${BASEPATH}/${SUBPATH}"

    # Cleanup
    terragrunt run-all destroy --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve || RETURN=1

    # Remove specific resources that sometimes get left behind (always return true, as resource may have been successfully been cleaned up)
    cleanup_roles "Velero"

    # Return false, if any *eseential* commands failed
    if [ $RETURN -ne 0 ]; then
        false
    fi
fi
