resource "aws_lambda_function" "lambda" {
  function_name = "${var.lambda_function_name}"
  role          = "${aws_iam_role.role.arn}"
  handler       = "${var.lambda_function_handler}.handler"
  runtime       = "${var.runtime}"

  s3_bucket = "${var.s3_bucket}"
  s3_key    = "${var.s3_key}" #"v1.0.0/example.zip"

  environment {
    variables = "${var.lambda_env_variables}"
  }
}




