# TODO: Refactor to make it more generic!

# CloudWatch Logs role ARN must be set in account settings to enable logging
resource "aws_api_gateway_account" "account" {
  cloudwatch_role_arn = "${aws_iam_role.cloudwatch.arn}"
}

resource "aws_api_gateway_stage" "latest" {
  stage_name    = "${var.api_gateway_stage}"
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  deployment_id = "${aws_api_gateway_deployment.deployment.id}"
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "${var.api_gateway_rest_api_name}"
}

resource "aws_api_gateway_resource" "parent_resource" {
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  
  path_part   = "root-redirect"
}

resource "aws_api_gateway_resource" "child_resource" {
  parent_id   = "${aws_api_gateway_resource.parent_resource.id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.child_resource.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "s" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "${aws_api_gateway_stage.latest.stage_name}"
  method_path = "*/*"  # "${aws_api_gateway_resource.child_resource.path_part}/${aws_api_gateway_method.test.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.child_resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${var.lambda_function_invoke_arn}"  
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = ["aws_api_gateway_integration.integration"]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.lambda_function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*"
}