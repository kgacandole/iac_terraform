# Lambda Function #

resource "aws_iam_policy" "backend_policy" {
  name        = "${var.prefix}-backend-policy"
  description = "backend function and resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DynamoDBAccess"
        Effect   = "Allow"
        Action   = ["dynamodb:*"]
        Resource = ["*"]
      },
      {
        Sid      = "CloudWatchAccess"
        Effect   = "Allow"
        Action   = ["logs:*"]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backend_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.backend_policy.arn
}

resource "aws_lambda_function" "backend_api" {
  function_name    = "${var.prefix}-backend-api"
  role             = aws_iam_role.lambda_role.arn
  filename         = "${path.module}/${var.package_build_path}"
  source_code_hash = filebase64sha256("${path.module}/${var.package_build_path}")
  runtime          = "python3.14"
  handler          = "lambda_handler"
}

# API Gateway #

resource "aws_apigatewayv2_api" "backend_apigw" {
  name          = "${var.prefix}-backend-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = ["Content-Type", "Authorization"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_origins = ["*"]
    max_age       = 300
  }
}

resource "aws_apigatewayv2_stage" "backend_apigw_stage" {
  api_id      = aws_apigatewayv2_api.backend_apigw.id
  name        = "$default"
  auto_deploy = true
}

# Lambda Integration #

resource "aws_apigatewayv2_integration" "backend_api_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.backend_apigw.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.backend_api.invoke_arn
  payload_format_version = "2.0"
}

# Default Route #

resource "aws_apigatewayv2_route" "backend_apigw_route" {
  api_id    = aws_apigatewayv2_api.backend_apigw.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.backend_api_lambda_integration.id}"
}

# Lambda Permission #

resource "aws_lambda_permission" "backend_api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.backend_apigw.execution_arn}/*/*"
}

# Dynamo DB #

resource "aws_dynamodb_table" "verses_db" {
  name         = "${var.prefix}-verses-db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "verse_reference"

  attribute {
    name = "verse_reference"
    type = "S"
  }
}