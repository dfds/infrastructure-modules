output "lambda_function_arn" {
  value = "${module.aws_lambda_edge_function.lambda_function_arn}"
}

output "lambda_function_qualified_arn" {
  value = "${module.aws_lambda_edge_function.lambda_function_qualified_arn}"
}
