resource "aws_lambda_function" "lambda" {
  count = "${var.deploy ? 1 :0}"
  function_name = "${var.lambda_function_name}"
  role          = "${aws_iam_role.role.arn}"
  handler       = "${var.lambda_function_handler}.handler"
  runtime       = "${var.runtime}"

  s3_bucket = "${var.s3_bucket}"
  s3_key    = "${var.s3_key}" 

  publish = "${var.publish}"
  
  dynamic "environment" { # Workarount for enabling empty map of environments 
    for_each = length(keys(var.lambda_env_variables)) > 0 ? [1]: []

    content {
      variables = "${var.lambda_env_variables}"
    }
  }
}