terragrunt state pull \
| jq -r '.resources[] | select(.module == "module.platform_fluxcd[0]") | select(.type == "kubectl_manifest") | select(.name == "install") | .instances[] | "\(.index_key) \(.attributes.kind) \(.attributes.name)"' \
| xargs -n3 sh -c 'terragrunt state mv module.platform_fluxcd[0].kubectl_manifest.install[\"$0\"] module.platform_fluxcd[0].kubectl_manifest.install[\"$1/$2\"]'

"apps/v1/deployment/flux-system/notification-controller"
"apiextensions.k8s.io/v1/customresourcedefinition/providers.notification.toolkit.fluxcd.io"
"v1/namespace/flux-system"
"apps/v1/deployment/flux-system/notification-controller"
"apiextensions.k8s.io/v1/customresourcedefinition/providers.notification.toolkit.fluxcd.io"
"v1/namespace/flux-system"
"rbac.authorization.k8s.io/v1/clusterrolebinding/cluster-reconciler-flux-system"
"rbac.authorization.k8s.io/v1/clusterrolebinding/cluster-reconciler-flux-system"
"apiextensions.k8s.io/v1/customresourcedefinition/kustomizations.kustomize.toolkit.fluxcd.io"
"apps/v1/deployment/flux-system/notification-controller"
"v1/namespace/flux-system"
"networking.k8s.io/v1/networkpolicy/flux-system/allow-webhooks"
"apiextensions.k8s.io/v1/customresourcedefinition/helmreleases.helm.toolkit.fluxcd.io"
"apiextensions.k8s.io/v1/customresourcedefinition/kustomizations.kustomize.toolkit.fluxcd.io"
"apps/v1/deployment/flux-system/helm-controller"

lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name])))

terragrunt state pull \
| jq -r '.resources[] | select(.module == "module.platform_fluxcd[0]") | select(.type == "kubectl_manifest") | select(.name == "install") | .instances[] | "\(.index_key) \(.attributes.kind) \(.attributes.name)"' \
| xargs -n3 sh -c 'terragrunt state mv module.platform_fluxcd[0].kubectl_manifest.install[\"$0\"] module.platform_fluxcd[0].kubectl_manifest.install[\"$1/$2\"]'

sed -e 's/\(.*\)/\L\1/'
