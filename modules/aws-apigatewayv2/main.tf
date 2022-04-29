resource "aws_apigatewayv2_api" "api"{
    name = var.api_name
    description = var.description
    protocol_type = "HTTP" 
}

resource "aws_apigatewayv2_integration" "integration_lambda" {
    for_each = var.apigateway
    api_id      = aws_apigatewayv2_api.api.id

    integration_type       = "AWS_PROXY"
    integration_uri        = each.value.integration_uri
    payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "route" {
    for_each = var.apigateway
    api_id    = aws_apigatewayv2_api.api.id
    route_key = each.value.route_key

    target = "integrations/${aws_apigatewayv2_integration.integration_lambda[each.key].id}"
}


resource "aws_apigatewayv2_stage" "default" {
    api_id      = aws_apigatewayv2_api.api.id
    name        = "$default"
    auto_deploy = true
}

## Lambda permissions
# for api gateway permissions
resource "aws_lambda_permission" "apigw_perm" {
    for_each = var.apigateway
    statement_id  = "AllowAPIGatewayInvoke"
    action        = "lambda:InvokeFunction"
    function_name = each.value.lambda_function_name
    principal     = "apigateway.amazonaws.com"

    # The /*/* portion grants access from any method on any resource
    # within the API Gateway "REST API".
    source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}