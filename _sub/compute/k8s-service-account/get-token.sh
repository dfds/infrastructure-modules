# Exit if any of the intermediate steps fail
set -e

eval "$(jq -r '@sh "CLUSTER_NAME=\(.cluster_name) DEFAULT_SECRET_NAME=\(.default_secret_name)"')"

# get token for sa
token=$(kubectl --kubeconfig ~/.kube/config_$CLUSTER_NAME -n kube-system get secret $DEFAULT_SECRET_NAME -o json | jq '.data.token' | tr -d '"' | base64 --decode)

# get current context
context=`kubectl --kubeconfig ~/.kube/config_$CLUSTER_NAME config current-context`

# get cluster name of context
name=`kubectl --kubeconfig ~/.kube/config_$CLUSTER_NAME config get-contexts $context | awk '{print $3}' | tail -n 1`

# get endpoint of current context 
endpoint=`kubectl --kubeconfig ~/.kube/config_$CLUSTER_NAME config view -o jsonpath="{.clusters[?(@.name == \"$name\")].cluster.server}"`
certificate=`kubectl --kubeconfig ~/.kube/config_$CLUSTER_NAME config view --raw -o jsonpath="{.clusters[?(@.name == \"$name\")].cluster.certificate-authority-data}"`

# generate kubeconfig
kubeconfig=$(cat <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: $endpoint
    certificate-authority-data: $certificate
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    user: deploy-user
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: deploy-user
  user:
    token: $token
KUBECONFIG
)

# return kubeconfig in json format
jq -n --arg kubeconfig_json "$kubeconfig" '{"kubeconfig_json": $kubeconfig_json}'