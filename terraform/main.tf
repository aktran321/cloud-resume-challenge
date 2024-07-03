data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_file = "${path.module}/aws_lambda/func.py"
  output_path = "${path.module}/aws_lambda/func.zip"
}

resource "aws_lambda_function" "myfunc" {
  filename         = data.archive_file.zip_the_python_code.output_path
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
  function_name    = "myfunc"
  role             = "arn:aws:iam::631242286372:role/service-role/cloud-resume-views-role-bnt3oikr"
  handler          = "func.lambda_handler"
  runtime          = "python3.12"
}

resource "aws_lambda_permission" "apigateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.myfunc.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.http_api.id}/*/GET/views"
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "views-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.myfunc.invoke_arn
  integration_method = "POST"
  payload_format_version = "1.0" # Explicitly set payload format version
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /views"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

output "http_api_url" {
  value = aws_apigatewayv2_stage.default_stage.invoke_url
}

data "aws_caller_identity" "current" {}