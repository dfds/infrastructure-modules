output "random_string" {
  value = "${element(concat(random_string.password.*.result, list("")), 0)}"
}
