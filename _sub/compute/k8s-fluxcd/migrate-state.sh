terragrunt state pull \
| jq -r '.resources[] | select(.module == "module.platform_fluxcd[0]") | select(.type == "kubectl_manifest") | select(.name == "install") | .instances[] | "\(.index_key) \(.attributes.kind) \(.attributes.name)"' \
| xargs -n3 sh -c 'terragrunt state mv module.platform_fluxcd[0].kubectl_manifest.install[\"$0\"] module.platform_fluxcd[0].kubectl_manifest.install[\"$1/$2\"]'


cat state.json \
| jq -r '.resources[] | select(.module == "module.platform_fluxcd[0]") | select(.type == "kubectl_manifest") | select(.name == "install") | .instances[] | "\(.index_key) \(.attributes.api_version) \(.attributes.kind) \(.attributes.namespace) \(.attributes.name)"' | sed -e 's/\(.*\)/\L\1/' \
| xargs -n5 sh -c 'echo $0 $1/$2/$3/$4' | sed 's/null\///g' | xargs -n2 sh -c 'echo terragrunt state mv module.platform_fluxcd[0].kubectl_manifest.install[\"$0\"] module.platform_fluxcd[0].kubectl_manifest.install[\"$1\"]'

# Actually do the state migration
terragrunt state pull \
| jq -r '.resources[] | select(.module == "module.platform_fluxcd[0]") | select(.type == "kubectl_manifest") | select(.name == "install") | .instances[] | "\(.index_key) \(.attributes.api_version) \(.attributes.kind) \(.attributes.namespace) \(.attributes.name)"' | sed -e 's/\(.*\)/\L\1/' \
| xargs -n5 sh -c 'echo $0 $1/$2/$3/$4' | sed 's/null\///g' | xargs -n2 sh -c 'terragrunt state mv module.platform_fluxcd[0].kubectl_manifest.install[\"$0\"] module.platform_fluxcd[0].kubectl_manifest.install[\"$1\"]'

# Copy-paste from terminal:

# apiextensions.k8s.io/v1/customresourcedefinition/helmreleases.helm.toolkit.fluxcd.io
# apiextensions.k8s.io/v1/customresourcedefinition/kustomizations.kustomize.toolkit.fluxcd.io
# apiextensions.k8s.io/v1/customresourcedefinition/providers.notification.toolkit.fluxcd.io
# apps/v1/deployment/flux-system/helm-controller
# apps/v1/deployment/flux-system/notification-controller
# networking.k8s.io/v1/networkpolicy/flux-system/allow-webhooks
# rbac.authorization.k8s.io/v1/clusterrolebinding/cluster-reconciler-flux-system
# v1/namespace/flux-system


# Output by migration command:

# apiextensions.k8s.io/v1/customresourcedefinition/gitrepositories.source.toolkit.fluxcd.io
# rbac.authorization.k8s.io/v1/clusterrolebinding/cluster-reconciler-flux-system
# v1/service/flux-system/notification-controller
# v1/serviceaccount/flux-system/kustomize-controller
# v1/service/flux-system/source-controller
# v1/serviceaccount/flux-system/helm-controller
# v1/service/flux-system/webhook-receiver
# apiextensions.k8s.io/v1/customresourcedefinition/helmrepositories.source.toolkit.fluxcd.io
# rbac.authorization.k8s.io/v1/clusterrole/crd-controller-flux-system
# networking.k8s.io/v1/networkpolicy/flux-system/deny-ingress
# apiextensions.k8s.io/v1/customresourcedefinition/receivers.notification.toolkit.fluxcd.io
# networking.k8s.io/v1/networkpolicy/flux-system/allow-webhooks
# v1/namespace/flux-system
# v1/serviceaccount/flux-system/source-controller
# rbac.authorization.k8s.io/v1/clusterrolebinding/crd-controller-flux-system
# v1/serviceaccount/flux-system/notification-controller
# networking.k8s.io/v1/networkpolicy/flux-system/allow-scraping
# apiextensions.k8s.io/v1/customresourcedefinition/buckets.source.toolkit.fluxcd.io
# apiextensions.k8s.io/v1/customresourcedefinition/helmcharts.source.toolkit.fluxcd.io
# apiextensions.k8s.io/v1/customresourcedefinition/providers.notification.toolkit.fluxcd.io