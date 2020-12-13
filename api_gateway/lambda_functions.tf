### lambda_functions ###
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
