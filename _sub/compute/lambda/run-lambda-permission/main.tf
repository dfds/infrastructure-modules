resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = var.principal
  source_arn    = var.source_arn
  qualifier     = var.lambda_alias_name
}