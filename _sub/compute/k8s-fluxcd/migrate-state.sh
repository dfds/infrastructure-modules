terragrunt state pull \
| jq -r '.resources[] | select(.module == "module.platform_fluxcd[0]") | select(.type == "kubectl_manifest") | select(.name == "install") | .instances[] | "\(.index_key) \(.attributes.kind) \(.attributes.name)"' \
| xargs -n3 sh -c 'terragrunt state mv module.platform_fluxcd[0].kubectl_manifest.install[\"$0\"] module.platform_fluxcd[0].kubectl_manifest.install[\"$1/$2\"]'