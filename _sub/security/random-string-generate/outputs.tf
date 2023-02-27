output "random_string" {
  value = element(concat(random_string.password[*].result, [""]), 0)
}

