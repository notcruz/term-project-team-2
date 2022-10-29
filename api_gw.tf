/*
 *  ========================================
 *             API Gateway
 *  ========================================
 */

resource "aws_apigatewayv2_api" "api_gw" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_gw" {
  api_id = aws_apigatewayv2_api.api_gw.id

  name        = "serverless_lambda_stage"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "api_gw" {
  api_id = aws_apigatewayv2_api.api_gw.id

  integration_uri    = aws_lambda_function.main_lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_gw" {
  api_id = aws_apigatewayv2_api.api_gw.id

  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.api_gw.id}"
}

/*
 *  ========================================
 *       Permission to Call Main Lambda
 *  ========================================
 */

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api_gw.execution_arn}/*/*"
}