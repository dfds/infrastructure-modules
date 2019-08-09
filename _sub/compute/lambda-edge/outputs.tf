output "lambda_function_arn" {
  value = "${element(concat(aws_lambda_function.lambda.*.arn, list("")), 0)}"
}

output "lambda_function_name" {
  value = "${var.lambda_function_name}"
}

output "lambda_function_invoke_arn" {
  value = "${element(concat(aws_lambda_function.lambda.*.invoke_arn, list("")), 0)}"
}

output "lambda_function_qualified_arn" {
  value = "${element(concat(aws_lambda_function.lambda.*.qualified_arn, list("")), 0)}"
}
