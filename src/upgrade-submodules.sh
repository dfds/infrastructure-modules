modules=$(grep -E "^\s+source\s+=\s+" main.tf | awk '{ print $3 }' | sed 's/\"//g')

for module in $modules; do
  pushd $module
  terraform init -backend=false
  terraform 0.12upgrade
  popd
done