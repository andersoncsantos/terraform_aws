output "lambda_invoke_arn" {
  value = aws_lambda_function.hello_lambda.invoke_arn
}

output "lambda_arn" {
  value = aws_lambda_function.hello_lambda.arn
}
