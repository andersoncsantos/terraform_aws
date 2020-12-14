provider "aws" {
  region                  = var.region
  shared_credentials_file = var.shared_credentials_file
  profile                 = var.profile
}

# api_gateway
resource "aws_api_gateway_rest_api" "api_test" {
  name        = "api_test"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_resource" "resource_test_1" {
  rest_api_id = aws_api_gateway_rest_api.api_test.id
  parent_id   = aws_api_gateway_rest_api.api_test.root_resource_id
  path_part   = "saldo-disponivel"
}

resource "aws_api_gateway_resource" "resource_test_2" {
  rest_api_id = aws_api_gateway_rest_api.api_test.id
  parent_id   = aws_api_gateway_resource.resource_test_1.id
  path_part   = "pv"
}

resource "aws_api_gateway_method" "saldo_disponivel_pv" {
  rest_api_id   = aws_api_gateway_rest_api.api_test.id
  resource_id   = aws_api_gateway_resource.resource_test_2.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_test.id
  resource_id = aws_api_gateway_resource.resource_test_2.id
  http_method = aws_api_gateway_method.saldo_disponivel_pv.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_test.id
  resource_id = aws_api_gateway_resource.resource_test_2.id
  http_method = aws_api_gateway_method.saldo_disponivel_pv.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello_lambda.invoke_arn

}

# lambda_function
data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "hello_lambda_role" {
  name               = "hello_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.policy.json
}


data "archive_file" "zip" {
  type        = "zip"
  source_file = "./data/hello_lambda.py"
  output_path = "./data/hello_lambda.zip"
}

resource "aws_lambda_function" "hello_lambda" {
  function_name = "hello_lambda"

  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  role    = aws_iam_role.hello_lambda_role.arn
  handler = "hello_lambda.lambda_handler"
  runtime = "python3.8"

  environment {
    variables = {
      greeting = "Hello"
    }
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api_test.execution_arn}/*/${aws_api_gateway_method.saldo_disponivel_pv.http_method}/${aws_api_gateway_resource.resource_test_1.path_part}/${aws_api_gateway_resource.resource_test_2.path_part}"

}

resource "aws_api_gateway_integration_response" "integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.api_test.id
  resource_id = aws_api_gateway_resource.resource_test_2.id
  http_method = aws_api_gateway_method.saldo_disponivel_pv.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}

resource "aws_api_gateway_deployment" "api_test_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_test.id
  stage_name  = "api_test"

  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_api_gateway_integration.lambda_integration),
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}
