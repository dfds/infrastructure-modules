output "goldpinger_chart_name" {
  value = length(helm_release.goldpinger) > 0 ? helm_release.goldpinger[0].name : ""
}

output "goldpinger_chart_version" {
  value = length(helm_release.goldpinger) > 0 ? helm_release.goldpinger[0].version : ""
}

output "goldpinger_chart_namespace" {
  value = length(helm_release.goldpinger) > 0 ? helm_release.goldpinger[0].namespace : ""
}