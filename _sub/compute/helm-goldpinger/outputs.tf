output "goldpinger_chart_name" {
  value = helm_release.goldpinger.name
}

output "goldpinger_chart_version" {
  value = helm_release.goldpinger.chart_version
}

output "goldpinger_chart_namespace" {
  value = helm_release.goldpinger.namespace
}